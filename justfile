default:
    @just --list

# Render the sorter's tray and holder and every example, failing on any warning
test:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(mktemp -d)
    for part in sieve holder; do
        echo "screw_sorter.scad: $part"
        openscad --hardwarnings --export-format binstl -D "render=\"$part\"" -o "$out/$part.stl" screw_sorter.scad
    done
    for f in examples/*.scad; do
        echo "$f"
        openscad --hardwarnings --export-format binstl -o "$out/example.stl" "$f"
    done
