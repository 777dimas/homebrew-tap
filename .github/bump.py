"""Bump Formula/gridhour.rb to the latest gridhour release on PyPI.

python3 -I .github/bump.py                      prints version=, url=, sha256= for GITHUB_OUTPUT if
                                                PyPI has a newer release, nothing otherwise
python3 -I .github/bump.py VERSION URL SHA256   writes them into the formula
"""
import json
import re
import sys
import urllib.request

FORMULA = "Formula/gridhour.rb"
VERSION = re.compile(r"[0-9]+(\.[0-9]+){1,3}")
URL = re.compile(r"https://files\.pythonhosted\.org/packages/[0-9a-f/]+/gridhour-([0-9.]+)\.tar\.gz")
SHA = re.compile(r"[0-9a-f]{64}")
# The formula's own url and sha256 are the first two in the file; the resources come after them.
FIELDS = re.compile(r'^(  url ")[^"]*("\n  sha256 ")[^"]*(")', re.M)


def current():
    with open(FORMULA, encoding="utf-8") as f:
        m = URL.search(f.read())
    if not m:
        sys.exit("bump: no gridhour url in " + FORMULA)
    return m.group(1)


def latest():
    with urllib.request.urlopen("https://pypi.org/pypi/gridhour/json", timeout=30) as r:
        info = json.load(r)
    version = info["info"]["version"]
    sdists = [u for u in info["urls"] if u["packagetype"] == "sdist"]
    if len(sdists) != 1:
        sys.exit("bump: expected one sdist for %s, found %d" % (version, len(sdists)))
    return version, sdists[0]["url"], sdists[0]["digests"]["sha256"]


def check(version, url, sha):
    """PyPI data is outside input: only accept what the formula can hold safely."""
    m = URL.fullmatch(url)
    if not (VERSION.fullmatch(version) and m and m.group(1) == version and SHA.fullmatch(sha)):
        sys.exit("bump: unexpected data from PyPI: %r %r %r" % (version, url, sha))


def newer(a, b):
    return tuple(map(int, a.split("."))) > tuple(map(int, b.split(".")))


def apply(version, url, sha):
    check(version, url, sha)
    with open(FORMULA, encoding="utf-8") as f:
        text = f.read()
    text, n = FIELDS.subn(lambda m: m.group(1) + url + m.group(2) + sha + m.group(3), text, count=1)
    if n != 1:
        sys.exit("bump: url/sha256 lines not found in " + FORMULA)
    with open(FORMULA, "w", encoding="utf-8") as f:
        f.write(text)
    print("bump: %s -> %s" % (FORMULA, version))


def main():
    if len(sys.argv) == 4:
        apply(*sys.argv[1:])
        return
    have = current()
    version, url, sha = latest()
    check(version, url, sha)
    if newer(version, have):
        print("version=%s\nurl=%s\nsha256=%s" % (version, url, sha))
    else:
        print("bump: formula has %s, PyPI has %s, nothing to do" % (have, version), file=sys.stderr)


if __name__ == "__main__":
    main()
