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

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

# Render the README picture into docs/img/: a tray sitting in its holder
images:
    @mkdir -p docs/img
    openscad --render --imgsize=900,600 --viewall --autocenter --camera=0,0,0,55,0,25,0 --colorscheme=Tomorrow -D 'render="all"' -o docs/img/tray-in-holder.png screw_sorter.scad

# Render the 1 mm to 10 mm trays and the holder into batch/, the set printed in 2025
batch:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p batch
    for g in 1 2 3 4 5 6 7 8 9 10; do
        openscad --hardwarnings --export-format binstl -D 'render="sieve"' -D "gap_size=$g" -o "batch/${g}mm.stl" screw_sorter.scad
    done
    openscad --hardwarnings --export-format binstl -D 'render="holder"' -o batch/holder.stl screw_sorter.scad
