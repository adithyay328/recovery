#!/usr/bin/env bash
set -euo pipefail

printf 'Have you audited recipients.txt? (y/n) ' >&2
read -r ans || { echo "Aborting: no answer received." >&2; exit 1; }
case "$ans" in
  y|Y) ;;
  *) echo "Aborting: audit recipients.txt first." >&2; exit 1 ;;
esac

IFS= read -r secret || { echo "Aborting: no secret line received." >&2; exit 1; }
printf '%s' "$secret" | age -R recipients.txt > enc.out.age