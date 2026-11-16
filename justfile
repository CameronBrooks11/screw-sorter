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

# Render the README picture into docs/img/: a tray sitting in its holder
images:
    @mkdir -p docs/img
    openscad --render --imgsize=900,600 --viewall --autocenter --camera=0,0,0,55,0,25,0 --colorscheme=Tomorrow -D 'render="all"' -o docs/img/tray-in-holder.png screw_sorter.scad
