#!/usr/bin/env bash
#
#SBATCH --job-name=du_space_check                                                            # the name of the job
#SBATCH -o /hpc/dhl_ec/du_space_check.log                                                   # the log file of this job
#SBATCH --error /hpc/dhl_ec/du_space_check.errors                                           # the error file of this job
#SBATCH --time=04:00:00                                                                      # the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=4G                                                                             # the amount of memory you think the script will consume
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                                          # where should be mailed to?
#SBATCH --mail-type=FAIL                                                                     # when do you want to receive a mail from your job?
####    Note:   'Current working directory is the calling process working directory unless the --chdir argument is passed.'
####            To submit: sbatch du_space_check.sh --input /hpc/dhl_ec [--log FILE] [--verbose]
#
# VERSION_NAME: du_space_check
# VERSION: 2.0.0
# VERSION_DATE: 2026-07-03
# AUTHOR: Sander W. van der Laan
# COPYRIGHT: Copyright 1979-2026. Sander W. van der Laan | MIT License
#
# Description:
#   Run "du -h --max-depth=2" on a given folder, dump results to a log file,
#   and report per-user (depth-1 subfolder) disk usage sorted largest-first,
#   identifying the top user.
#
#   Can be submitted as a SLURM job (sbatch) or run interactively.
#
#   Usage:
#     sbatch du_space_check.sh --input /hpc/dhl_ec [--log FILE] [--verbose]
#     bash   du_space_check.sh --input /hpc/dhl_ec [--log FILE] [--verbose]
#

set -euo pipefail

show_help() {
  cat << EOF
Usage: $(basename "$0") --input DIR [--log FILE] [--verbose] [--help]

Options:
  --input DIR     Folder to check (required).
  --log FILE      Log file path. Defaults to DIR/YYYYMMDD.du_space_check.log.
  --verbose       Print progress messages to the terminal / SLURM stdout.
  --help          Show this help message and exit.

Examples:
  $(basename "$0") --input /hpc/dhl_ec
  $(basename "$0") --input /hpc/dhl_ec --log /tmp/space.log --verbose

Submit as a SLURM job:
  sbatch $(basename "$0") --input /hpc/dhl_ec --verbose
EOF
}

INPUT=""
LOG=""
VERBOSE=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --input)   INPUT=$2;  shift 2 ;;
    --log)     LOG=$2;    shift 2 ;;
    --verbose) VERBOSE=1; shift   ;;
    --help)    show_help; exit 0  ;;
    *)         echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Error: --input is required."
  show_help
  exit 1
fi

if [[ ! -d "$INPUT" ]]; then
  echo "Error: $INPUT is not a directory."
  exit 1
fi

DATESTAMP=$(date +%Y%m%d)

if [[ -z "$LOG" ]]; then
  LOG="${INPUT}/${DATESTAMP}.du_space_check.log"
fi

USER_LOG="${LOG%.log}.per_user.log"

[[ $VERBOSE -eq 1 ]] && echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') Running disk usage check on: $INPUT"
[[ $VERBOSE -eq 1 ]] && echo "[INFO] Full depth-2 log : $LOG"
[[ $VERBOSE -eq 1 ]] && echo "[INFO] Per-user log     : $USER_LOG"

# ── 1. Full depth-2 scan ──────────────────────────────────────────────────────
[[ $VERBOSE -eq 1 ]] && echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') Starting du --max-depth=2 ..."
du -h --max-depth=2 "$INPUT" 2>/dev/null | tee "$LOG" > /dev/null
[[ $VERBOSE -eq 1 ]] && echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') du --max-depth=2 complete."

# ── 2. Per-user (depth-1) summary ─────────────────────────────────────────────
[[ $VERBOSE -eq 1 ]] && echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') Computing per-user (depth-1) usage ..."

# Collect depth-1 entries in bytes for reliable numeric sort, then humanise.
# Skip the root entry itself (path == INPUT) and hidden dirs starting with dot.
declare -A USER_BYTES
declare -A USER_HUMAN

while IFS=$'\t' read -r size_k path; do
  # skip the root itself
  [[ "$path" == "$INPUT" ]] && continue
  # skip if not exactly one level deep
  subpath="${path#"$INPUT"/}"
  [[ "$subpath" == */* ]] && continue
  # skip dot-directories
  dirname="$(basename "$path")"
  [[ "$dirname" == .* ]] && continue

  USER_BYTES["$dirname"]=$((size_k * 1024))
  USER_HUMAN["$dirname"]=$(du -sh "$path" 2>/dev/null | cut -f1)
done < <(du --max-depth=1 -k "$INPUT" 2>/dev/null)

if [[ ${#USER_BYTES[@]} -eq 0 ]]; then
  echo "[WARN] No subdirectories found in $INPUT." | tee "$USER_LOG"
  exit 0
fi

# Sort by bytes descending and format the report
{
  echo "========================================================================"
  echo " Disk usage per user in: $INPUT"
  echo " Generated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "========================================================================"
  printf "%-12s  %s\n" "SIZE" "USER / FOLDER"
  echo "------------------------------------------------------------------------"

  TOP_USER=""
  TOP_BYTES=0

  # Build a sortable list: bytes<TAB>user
  for user in "${!USER_BYTES[@]}"; do
    echo "${USER_BYTES[$user]}	$user"
  done | sort -rn | while IFS=$'\t' read -r bytes user; do
    human="${USER_HUMAN[$user]}"
    printf "%-12s  %s\n" "$human" "$user"
  done

  echo "------------------------------------------------------------------------"

  # Identify top user (pure bash, no sub-shell so we can print after the loop)
  for user in "${!USER_BYTES[@]}"; do
    if (( USER_BYTES["$user"] > TOP_BYTES )); then
      TOP_BYTES=${USER_BYTES["$user"]}
      TOP_USER="$user"
    fi
  done
  TOP_HUMAN="${USER_HUMAN[$TOP_USER]}"
  echo " Largest user: $TOP_USER  ($TOP_HUMAN)"
  echo "========================================================================"
} | tee "$USER_LOG"

[[ $VERBOSE -eq 1 ]] && echo "[INFO] Per-user log written to: $USER_LOG"
[[ $VERBOSE -eq 1 ]] && echo "[INFO] Done."
