#!/usr/bin/env python2

from __future__ import print_function

import os
import pipes
import sys
import argparse
import collections
import glob
import gzip
import re
import shutil
import textwrap

if sys.version_info.major == 2:
    input = raw_input

COLUMNS = 120
ROOT = '/home/llandsmeer/Data/hpc/data/_ae_originals/'
FILE1 = 'AEGS1_AffySNP5/AEGS1_SNP5_1000Gp3HRCr11/aegs1.1kgp3hrcr11.chr1.dose.vcf.gz'
FILE2 = 'AEGS2_AffyAxiomGWCEU1/AEGS2_AxiomGWCEU_1000Gp3HRCr11/aegs2.1kgp3hrcr11.chr1.dose.vcf.gz'
FILE3 = 'AEGS3_GSA/AEGS3_GSA_1000Gp3HRCr11/aegs3.1kgp3hrcr11.chr1.dose.vcf.gz'
JOBROOT = '/home/llandsmeer/Data/hpc/llandsmeer/ae'
QCTOOLv2 = 'qctool_v2.0.1'

VCF_HEADER = '#CHROM POS ID REF ALT QUAL FILTER INFO FORMAT'.split()

if os.path.exists('/hpc/dhl_ec'):
    ROOT = '/hpc/dhl_ec/data/_ae_originals/'
    JOBROOT = '/hpc/dhl_ec/llandsmeer/ae/jobs'
    QCTOOLv2 = 'qctool_v2'

def vcf_filename(aegs, chrm):
    assert 1 <= aegs <= 3
    assert 1 <= chrm <= 22
    filename = [FILE1, FILE2, FILE3][aegs - 1]
    filename = ROOT + filename
    filename = filename.replace('chr1', 'chr{chrm}'.format(chrm=chrm))
    return filename

def get_vcf_ids(filename):
    with gzip.open(filename, 'rt') as src:
        for line in src:
            if line.startswith('#CHROM'):
                break
        line = line.split()
        if line[:len(VCF_HEADER)] != VCF_HEADER:
            print('not a vcf file?')
            print(' '.join(line)[:30], '...')
            exit(1)
        del line[:len(VCF_HEADER)]
        for id_ in line:
            yield id_

def get_conflicts(human=False):
    ar = list(get_vcf_ids(ROOT + FILE1))
    br = list(get_vcf_ids(ROOT + FILE2))
    cr = list(get_vcf_ids(ROOT + FILE3))
    samples = collections.defaultdict(list)
    for id_ in ar:
        patient = id_.split('-')[0]
        samples[patient].append((1, id_))
    for id_ in br:
        patient = id_.split('_')[0]
        samples[patient].append((2, id_))
    for id_ in cr:
        patient = id_.split('_')[0]
        samples[patient].append((3, id_))
    conflicts = []
    for k, v in samples.items():
        if 'UPID' in k and len(v) > 1:
            conflicts.append(v)
    if human:
        for i, conflict in enumerate(conflicts):
            conflicts[i] = '/'.join('AEGS{a}:{b}'.format(a=a, b=b) for a, b in conflict)
    return conflicts

def readvcf(filename=None):
    # ID=GT,Type=String,Number=1,Description="Genotype"
    # ID=DS,Type=Float,Number=1,Description="Estimated Alternate Allele Dosage : [P(0/1)+2*P(1/1)]"
    # ID=GP,Type=Float,Number=3,Description="Estimated Posterior Probabilities for Genotypes 0/0, 0/1 and 1/1 "
    filename = ROOT + FILE1
    for line in gzip.open(filename, 'rt'):
        if line.startswith('#CHROM'):
            samples = line[len(VCF_HEADER):]
            continue
        elif line.startswith('#'):
            continue
        line = line.split()
        mutation = dict(zip(VCF_HEADER, line))
        assert mutation['FORMAT'] == 'GT:DS:GP'
        bysample = []
        for idx, cell in enumerate(line[len(VCF_HEADER):]):
            gt, ds, gp = cell.split(':')
            exit(1)
            bysample[samples[idx]] = { 'gt': gt, 'ds': ds, 'gp': gp }
            # gt 0|0
            # ds 0.826
            # gp 0.345,0.485,0.17

def resolve_conflicts(root):
    if not os.path.exists(root):
        print('jobdir not found')
        exit(1)
    conflicts = get_conflicts(human=True)
    conflicting_samplies = set()
    for conflict in conflicts:
        conflicting_samplies.update(conflict.split('/'))
    pattern = os.path.join(root, '*.dat')
    files = glob.glob(pattern)
    if not files:
        print('no files matches pattern', pattern)
        exit(1)
    gt_counts_by_sample = collections.defaultdict(int)
    for filename in files:
        with open(filename) as src:
            for line in src:
                line = line.split()
                sample = line[0]
                if sample not in conflicting_samplies:
                    continue
                gt = sum(map(int, line[2:])) # sum of 0|1 1|0 1|1
                gt_counts_by_sample[sample] += gt
    for conflict in conflicts:
        samples = conflict.split('/')
        counts = [gt_counts_by_sample[sample] for sample in samples]
        winner_idx = counts.index(max(counts))
        s = '/'.join(map(str, counts)) + ' ' + samples[winner_idx]
        yield {
            'samples': samples,
            'counts': counts,
            'human': s,
            'winner': samples[winner_idx],
            'conflict': conflict
        }

# cli

def prog_vcf_sample_ids(args):
    if not 1 <= args.N <= 3:
        print('file <N> must be one of 1, 2 or 3')
    filename = [FILE1, FILE2, FILE3][args.N - 1]
    filename = ROOT + filename
    for id_ in get_vcf_ids(filename):
        print(id_)

def prog_vcf_duplicates(args):
    ar = list(get_vcf_ids(ROOT + FILE1))
    br = list(get_vcf_ids(ROOT + FILE2))
    cr = list(get_vcf_ids(ROOT + FILE3))
    print('Raw duplicates within vcf?')
    print('  AEGS1:', len(ar) != len(set(ar)))
    print('  AEGS2:', len(br) != len(set(br)))
    print('  AEGS3:', len(cr) != len(set(cr)))
    a = collections.Counter(x.split('-')[0] for x in ar)
    b = collections.Counter(x.split('_')[0] for x in br)
    c = collections.Counter(x.split('_')[0] for x in cr)
    print('Patient duplicates within vcf?')
    def do(a):
        text = ' '.join(k for k, v in a.items() if v > 1 and 'UPID' in k)
        for line in textwrap.wrap(text, COLUMNS - 4):
            print('   ', line)
        if not text:
            print('    (none)')
    print('  - AEGS1')
    do(a)
    print('  - AEGS2')
    do(b)
    print('  - AEGS3')
    do(c)
    print('Non-UPID patient IDS')
    def do2(ar):
        text = [x for x in ar if 'UPID' not in x]
        for line in text:
            print('   ', line)
        if not text:
            print('    (none)')
    print('  - AEGS1')
    do2(ar)
    print('  - AEGS2')
    do2(br)
    print('  - AEGS3')
    do2(cr)
    print('CrossDup. AEGS1 AEGS2 AEGS3')
    print('    AEGS1 {q: 5} {w: 5} {e: 5}'.format(q=len(a&a), w=len(a&b), e=len(a&c)))
    print('    AEGS2 {q: 5} {w: 5} {e: 5}'.format(q=len(b&a), w=len(b&b), e=len(b&c)))
    print('    AEGS3 {q: 5} {w: 5} {e: 5}'.format(q=len(c&a), w=len(c&b), e=len(c&c)))
    print('Total unique (All) :', len(a | b | c))
    print('Total unique (UPID):', len([x for x in (a | b | c) if 'UPID' in x]))
    print('Total conflicts:', len(get_conflicts()))

def prog_conflicts(args):
    for conflict in get_conflicts(human=True):
        print(conflict)

def prog_missing(args):
    db = args.aegs
    chrom = args.chr
    maxvariants = args.maxvariants
    maxsamples = args.maxsamples
    every = args.every
    nvariants = 0
    filename = vcf_filename(db, chrom)

    # ID=GT,Type=String,Number=1,Description="Genotype"
    # ID=DS,Type=Float,Number=1,Description="Estimated Alternate Allele Dosage : [P(0/1)+2*P(1/1)]"
    # ID=GP,Type=Float,Number=3,Description="Estimated Posterior Probabilities for Genotypes 0/0, 0/1 and 1/1 "
    filename = vcf_filename(db, chrom)
    nheader = len(VCF_HEADER)
    GT = ['0|0', '0|1', '1|0', '1|1']
    for line in gzip.open(filename, 'rt'):
        if line.startswith('#CHROM'):
            samples = line.split()[nheader:]
            gtbysample = [[0, 0, 0, 0] for _i in samples]
            continue
        elif line.startswith('#'):
            continue
        nvariants += 1
        if nvariants % every != 0:
            continue
        line = line.split()
        mutation = dict(zip(VCF_HEADER, line))
        assert mutation['FORMAT'] == 'GT:DS:GP'
        for idx in range(nheader, len(line)):
            gt = line[idx].split(':', 1)[0]
            jdx = GT.index(gt)
            current = gtbysample[idx - nheader][jdx]
            gtbysample[idx - nheader][jdx] = current + 1
        if maxvariants and nvariants >= maxvariants:
            break
    i = 0
    for sample, gt_counts in zip(samples, gtbysample):
        print('AEGS{db}:{sample} {out}'.format(db=db, sample=sample, out=" ".join(map(str, gt_counts))))
        i += 1
        if maxsamples and i >= maxsamples:
            break

def getconfirm(args=None):
    for i in range(3):
        try:
            ans = input('Confirm? <y/n>').lower()
        except KeyboardInterrupt:
            return False
        if ans == 'y':
            return True
        if ans == 'n':
            return False
    return False

def prog_qsub_missing(args):
    jobid = args.jobid
    maxvariants = args.maxvariants or 0
    maxsamples = args.maxsamples or 0
    every = args.every
    fullpath = os.path.abspath(__file__)
    jobdir = JOBROOT + '/' + jobid + '/'
    ncommands = 0
    job_commands_file = jobdir + 'commands.sh'
    if every == 1:
        print('WARNING: --every <N> not specified')
        print('This will probably take very long')
    try:
        os.makedirs(jobdir)
    except OSError:
        print('Jobdir already exists')
        print('Delete?')
        if getconfirm(args):
            shutil.rmtree(jobdir)
            os.makedirs(jobdir)
        else:
            exit(1)
    print('###', job_commands_file, '###')
    with open(job_commands_file, 'w') as jobfile:
        for aegs in 1, 2, 3:
            for chrom in range(1, 22+1):
                filename = vcf_filename(aegs, chrom)
                if not os.path.exists(filename):
                    continue
                command = ' '.join(map(str, [fullpath, 'missing',
                        '--aegs', aegs,
                        '--chr', chrom,
                        '--maxvariants', maxvariants,
                        '--maxsamples', maxsamples,
                        '--every', every]))
                to = '{jobdir}AEGS{aegs}-chr{chrom}.dat'.format(
                        jobdir=jobdir, aegs=aegs, chrom=chrom)
                print(command)
                print('   >', to)
                print(command, '>', to, file=jobfile)
                ncommands += 1
    qsub_file = jobdir + 'qsub.sh'
    print()
    print('###', qsub_file, '###')
    with open(qsub_file, 'w') as f:
        qsub = textwrap.dedent('''\
        #$ -t 1-{ncommands}
        #$ -S /bin/bash
        #$ -e {e}
        #$ -o {o}
        #$ -N {N}
        #$ -l h_rt=02:00:00
        #$ -l s_rt=00:30:00
        set -ex
        sed "${{SGE_TASK_ID}}"'p;d' {job_commands_file} | sh
        '''.format(
            ncommands=ncommands,
            jobdir=jobdir,
            e=jobdir + "qsub.errors",
            o=jobdir + "qsub.errors",
            N="ae-missing-" + jobid,
            job_commands_file=job_commands_file
            ))
        print(qsub)
        print(qsub, file=f)
    print()
    print('qsub {qsub_file}'.format(qsub_file=qsub_file))
    if not getconfirm(args):
        exit(2)
    os.system('qsub {qsub_file}'.format(qsub_file=qsub_file))
    os.system('qstat')

def prog_resolve_conflicts(args):
    full = args.full
    if os.path.exists(args.jobid):
        root = args.jobid
    else:
        root = os.path.join(JOBROOT, args.jobid)
    for solution in resolve_conflicts(root):
        if full:
            print(solution['conflict'], solution['human'])
        else:
            print(solution['human'])

def prog_loadenv(args):
    envsh = '/tmp/ae-load-env.sh'
    with open(envsh, 'w') as f:
        for aegs in 1, 2, 3:
            for chrom in range(1, 22+1):
                filename = vcf_filename(aegs, chrom)
                if not os.path.exists(filename):
                    continue
                print('AEGS{0}CHR{1}={2}'.format(
                    aegs, chrom, filename), file=f)
    print('Please run:')
    print('.', envsh)
    print('Variables: AEGS{1-3}CHR{1-22}')

def prog_write_sample_conflict_files(args):
    inp_jobid = args.qsub_missing_jobname
    out_jobid = args.jobname
    out_root = os.path.join(JOBROOT, out_jobid)
    if os.path.exists(inp_jobid):
        inp_root = inp_jobid
    else:
        inp_root = os.path.join(JOBROOT, inp_jobid)
    try:
        os.makedirs(out_root)
    except OSError:
        print('Output samples jobdir already exists')
        print('Delete?')
        if getconfirm(args):
            shutil.rmtree(out_root)
            os.makedirs(out_root)
        else:
            exit(1)
    solutions = list(resolve_conflicts(inp_root))
    exclusions = collections.defaultdict(set)
    for solution in solutions:
        for sample in solution['samples']:
            if sample != solution['winner']:
                db, sample_id = sample.split(':')
                assert db.startswith('AEGS') and len(db) == 5
                db = int(db[-1])
                exclusions[db].add(sample_id)
    exclude_counter = 0
    for aegs in 1, 2, 3:
        outfile = os.path.join(out_root, 'AEGS{0}.sample'.format(aegs))
        with open(outfile, 'w') as f:
            print('ID_1 ID_2 missing', file=f)
            print('0 0 0', file=f)
            filename = vcf_filename(aegs, 1)
            for sample_id in get_vcf_ids(filename):
                if sample_id in exclusions[aegs]:
                    exclude = 'EXCLUDE{0}'.format(exclude_counter)
                    print(exclude, exclude, 0, file=f)
                    exclude_counter += 1
                else:
                    sample_id = sample_id.replace('-', '_')
                    dupl_test = sample_id.split('_')
                    if dupl_test[0] == dupl_test[1]:
                        dupl_test.pop(0)
                        sample_id = '_'.join(dupl_test)
                    print(sample_id, sample_id, 0, file=f)
        print('wrote', outfile)
    outfile = os.path.join(out_root, 'excl-samples')
    with open(outfile, 'w') as f:
        for i in range(exclude_counter):
            print('EXCLUDE{0}'.format(i), file=f)
    print('wrote', outfile)
    return out_root

def prog_merge(args):
    root = prog_write_sample_conflict_files(args)
    merge_sh = os.path.join(root, 'merge.sh')
    commands = []
    print()
    print('###', merge_sh, '###')
    ncommands = 0
    with open(merge_sh, 'w') as f:
        for ch in range(1, 22+1):
            if not os.path.exists(vcf_filename(1, ch)):
                continue
            outgen = os.path.join(root, 'aegs-mid-chr{0}.vcf.gz'.format(ch))
            outgen_sam = os.path.join(root, 'aegs-mid-chr{0}.samples'.format(ch))
            outgen_fix = os.path.join(root, 'aegs-merge-chr{0}.vcf.gz'.format(ch))
            command = [
                QCTOOLv2,
                '-g', vcf_filename(1, ch),
                '-s', os.path.join(root, 'AEGS1.sample'),
                '-g', vcf_filename(2, ch),
                '-s', os.path.join(root, 'AEGS2.sample'),
                '-g', vcf_filename(3, ch),
                '-s', os.path.join(root, 'AEGS3.sample'),
                '-excl-samples', os.path.join(root, 'excl-samples'),
                '-og', outgen,
                '-os', outgen_sam,
                '&&',
                os.path.abspath(__file__),
                'rewrite-vcf',
                '--input', outgen,
                '--output', outgen_fix,
            ]
            ncommands += 1
            stdout = os.path.join(root, 'chr{0}.output'.format(ch))
            stderr = os.path.join(root, 'chr{0}.error'.format(ch))
            if ch == 1:
                print('$', command[0])
                for a, b in zip(command[1::2], command[2::2]):
                    print('   ', a, b)
                print('  >', stdout)
                print(' 2>', stderr)
            command = 'sh -c ' + pipes.quote(' '.join(command))
            print(command, '>', stdout, '2>', stderr, file=f)
    print('... and', ncommands - 1, 'other commands')
    print()
    qsub_sh = os.path.join(root, 'qsub.sh')
    print('###', qsub_sh, '###')
    with open(qsub_sh, 'w') as f:
        script = textwrap.dedent('''\
        #$ -t 1-{ncommands}
        #$ -S /bin/bash
        #$ -e {e}
        #$ -o {o}
        #$ -N {N}
        #$ -l h_rt=02:00:00
        #$ -l s_rt=00:30:00
        set -ex
        sed "${{SGE_TASK_ID}}"'p;d' {job_commands_file} | sh
        '''.format(
            ncommands=ncommands,
            e=os.path.join(root, 'qsub.error'),
            o=os.path.join(root, 'qsub.output'),
            N='ae-merge',
            job_commands_file=merge_sh
            )).lstrip()
        print(script)
        with open(qsub_sh, 'w') as f:
            print(script, file=f)
    print('$ qsub {qsub_sh}'.format(qsub_sh=qsub_sh))
    print('(you might want to run this command on completion:')
    print('$ rename aegs-merge-chr aegs_combo_1000g_hrc_chr -v *.vcf.gz')
    print(')')
    print('Submit to SGE?')
    if not getconfirm(args):
        exit(2)
    os.system('qsub {qsub_sh}'.format(qsub_sh=qsub_sh))
    os.system('qstat')


def prog_rewrite_vcf(args):
    with gzip.open(args.output, 'wt') as f:
        for lineno, line in enumerate(gzip.open(args.input, 'rt'), 1):
            line = line.rstrip()
            if line[0] == '#':
                print(line, file=f)
            else:
                line = line.split()
                line[2] = line[2].replace(',.', '')
                for idx in range(8, len(line)):
                    parts = line[idx].split(':')
                    parts.insert(0, parts.pop())
                    line[idx] = ':'.join(parts)
                    if idx == 8:
                        assert line[idx] == 'GT:DS:GP'
                print('\t'.join(line), file=f)


parser = argparse.ArgumentParser(description='_ae_originals tool.')
subparsers = parser.add_subparsers(title='command', metavar='')

sub = subparsers.add_parser('vcf-ids', help='list vcf sample ids in AEGS<N>')
sub.add_argument('N', type=int)
sub.set_defaults(func=prog_vcf_sample_ids)

sub = subparsers.add_parser('vcf-duplicates', help='show duplicates statistics')
sub.set_defaults(func=prog_vcf_duplicates)

sub = subparsers.add_parser('conflicts', help='list all conflicts (duplicates) across aegs datasets')
sub.set_defaults(func=prog_conflicts)

sub = subparsers.add_parser('missing', help='calculate actual/imputed variant counts')
sub.add_argument('--aegs', metavar='N', type=int, help='Dataset')
sub.add_argument('--chr', type=int, help='Chromosome')
sub.add_argument('--maxvariants', type=int, default=None, help='Stop after <maxvariants> variants')
sub.add_argument('--maxsamples', type=int, default=None, help='Stop after <maxsamples> samples')
sub.add_argument('--every', type=int, default=1, help='Speed up processing by only analyzing one in <every> variants')
sub.set_defaults(func=prog_missing)

sub = subparsers.add_parser('qsub-missing', help='Interactively sumbit `missing` jobs to SGE')
sub.add_argument('jobid', help='Name for the job - eg. directory names etc')
sub.add_argument('--maxvariants', type=int, default=None, help='Stop after <maxvariants> variants')
sub.add_argument('--maxsamples', type=int, default=None, help='Stop after <maxsamples> samples')
sub.add_argument('--every', type=int, default=1, help='Speed up processing by only analyzing one in <every> variants')
sub.set_defaults(func=prog_qsub_missing)

sub = subparsers.add_parser('resolve-conflicts', help='Read qsub-missing results and resolve conflicts')
sub.add_argument('jobid', help='Path or jobid name of the qsub-missing job')
sub.add_argument('--full', help='Provide verbose output', default=False, action='store_true')
sub.set_defaults(func=prog_resolve_conflicts)

sub = subparsers.add_parser('load-env', help='Prints useful env variables')
sub.set_defaults(func=prog_loadenv)

sub = subparsers.add_parser('resolve-conflicts-write-sample', help='Read qsub-missing results and resolve conflicts')
sub.add_argument('--qsub-missing-jobname', required=True, help='Path or jobid name of the qsub-missing job')
sub.add_argument('--samples-dir', required=True, metavar='DIR', help='Output to <DIR>/AEGS{1,2,3}.sample')
sub.set_defaults(func=prog_write_sample_conflict_files)

sub = subparsers.add_parser('qsub-merge', help='Sumbit merge operation to SGE')
sub.add_argument('--qsub-missing-jobname', required=True, help='Path or jobid name of the qsub-missing job')
sub.add_argument('--jobname', required=True, metavar='DIR', help='Output to <DIR>/AEGS{1,2,3}.sample')
sub.set_defaults(func=prog_merge)

sub = subparsers.add_parser('rewrite-vcf', help='Fix broken vcf output from qctool')
sub.add_argument('--input', required=True, help='Input vcf.gz')
sub.add_argument('--output', required=True, help='Output vcf.gz')
sub.set_defaults(func=prog_rewrite_vcf)

args = parser.parse_args()
if not hasattr(args, 'func'):
    print('no subcommand given')
    parser.print_help()
    exit(1)
args.func(args)
