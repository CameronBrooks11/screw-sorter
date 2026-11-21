"""Render the tray, the holder and every example, and check the parts fit.

usage: python3 tests/test_screw_sorter.py [OPENSCAD]

- Each part and example renders with --hardwarnings and no WARNING or ERROR
  line: OpenSCAD exits 0 on a failed assert, so the exit status alone misses one.
- The tray is 120 x 120 x 5 mm; the holder is 126.5 x 126.5 x 20 mm, the tray
  plus two rims (2 x 3 mm) and the insert allowance (0.5 mm).
- A tray sits in its holder without overlap: render="all" has exactly the
  volume of the two parts added up.
- Two holders stack without overlap: one 15 mm (3 x rim_height) above the
  other, so its female ring sits over the lower one's male ring.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SORTER = os.path.join(ROOT, "screw_sorter.scad")

results = []


def check(label, ok, got):
    results.append(bool(ok))
    print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")


def render(openscad, src, out, *args):
    r = subprocess.run([openscad, "--hardwarnings", "--export-format", "binstl", *args, "-o", out, src],
                       capture_output=True, text=True)
    bad = [l for l in r.stderr.splitlines() if l.startswith(("WARNING", "ERROR"))]
    return r.returncode == 0 and not bad, (bad[:1] or [f"exit {r.returncode}"])[0]


def mesh(path):
    """Signed volume and bounding-box size of a binary STL."""
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    vol, lo, hi = 0.0, [1e9] * 3, [-1e9] * 3
    for i in range(n):
        t = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        a, b, c = t[0:3], t[3:6], t[6:9]
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
        for p in (a, b, c):
            for k in range(3):
                lo[k], hi[k] = min(lo[k], p[k]), max(hi[k], p[k])
    return vol, [hi[k] - lo[k] for k in range(3)]


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    with tempfile.TemporaryDirectory() as tmp:
        parts = {}
        for part, want in (("sieve", [120, 120, 5]), ("holder", [126.5, 126.5, 20])):
            stl = os.path.join(tmp, f"{part}.stl")
            ok, why = render(openscad, SORTER, stl, "-D", f'render="{part}"')
            check(f"{part} renders", ok, why if not ok else "no warnings")
            if not ok:
                return
            parts[part], size = mesh(stl)
            check(f"{part} size", all(abs(s - w) < 0.01 for s, w in zip(size, want)),
                  f"{' x '.join(f'{s:.2f}' for s in size)} mm; want {' x '.join(map(str, want))}")

        examples = sorted(f for f in os.listdir(os.path.join(ROOT, "examples")) if f.endswith(".scad"))
        for f in examples:
            ok, why = render(openscad, os.path.join(ROOT, "examples", f), os.path.join(tmp, "example.stl"))
            check(f"examples/{f} renders", ok, why if not ok else "no warnings")

        stl = os.path.join(tmp, "all.stl")
        ok, why = render(openscad, SORTER, stl, "-D", 'render="all"')
        vol = mesh(stl)[0] if ok else 0
        want = parts["sieve"] + parts["holder"]
        check("tray sits in its holder without overlap", ok and abs(vol - want) < 0.5,
              f"{vol:.1f} mm3; the two alone {want:.1f}" if ok else why)

        probe = os.path.join(tmp, "stack.scad")
        with open(probe, "w") as f:
            f.write('import("holder.stl");\ntranslate([0, 0, 15]) import("holder.stl");\n')
        stl = os.path.join(tmp, "stack.stl")
        ok, why = render(openscad, probe, stl)
        vol = mesh(stl)[0] if ok else 0
        check("two holders stack without overlap", ok and abs(vol - 2 * parts["holder"]) < 0.5,
              f"{vol:.1f} mm3; two alone {2 * parts['holder']:.1f}" if ok else why)

    print(f"{sum(results)} of {len(results)} checks passed")


if __name__ == "__main__":
    main()
    sys.exit(0 if results and all(results) else 1)
