#!/usr/bin/env bash
set -euo pipefail

ciphertext="${1:-enc.out.age}"

if ! systemctl is-active --quiet pcscd 2>/dev/null; then
  echo "pcscd is not running. Run: sudo systemctl start pcscd" >&2
  exit 1
fi

identities=()
for f in *.identity.txt; do
  [[ -e "$f" ]] || continue
  identities+=(-i "$f")
done
if [[ ${#identities[@]} -eq 0 ]]; then
  echo "No *.identity.txt files found in $(pwd)." >&2
  exit 1
fi

[[ -f "$ciphertext" ]] || { echo "No such file: $ciphertext" >&2; exit 1; }

echo "Enter YubiKey PIN if prompted; touch the key when it blinks." >&2
age -d "${identities[@]}" "$ciphertext"