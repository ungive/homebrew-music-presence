import fileinput
import json
import re
import os.path
import urllib.request

repo = "ungive/discord-music-presence"
latest_url = f"https://api.github.com/repos/{repo}/releases/latest"

with urllib.request.urlopen(latest_url) as response:
    data = json.load(response)
    tag_name: str = data["tag_name"]
    assert tag_name.startswith("v")
    latest_version = tag_name[1:]

ARM_NAME = "arm64"
INTEL_NAME = "x86_64"
SHA256_LEN = 64

arm_hash = None
intel_hash = None

shasums_url = f"https://github.com/ungive/discord-music-presence/releases/download/v{latest_version}/sha256sum.txt"
for shasum in urllib.request.urlopen(shasums_url):
    shasum = shasum.decode("utf-8")
    if not " " in shasum:
        continue
    if ARM_NAME in shasum:
        arm_hash = shasum.split(" ")[0]
        continue
    if INTEL_NAME in shasum:
        intel_hash = shasum.split(" ")[0]
        continue

assert arm_hash is not None
assert intel_hash is not None
assert len(arm_hash) == SHA256_LEN
assert len(intel_hash) == SHA256_LEN

print("version", latest_version)
print("sha256 arm", arm_hash)
print("sha256 intel", intel_hash)
print("verify:", shasums_url)

script_path = os.path.dirname(os.path.realpath(__file__))
cask_file = os.path.join(script_path, "..", "Casks", "music-presence.rb")

has_version = False
has_arm_hash = False
has_intel_hash = False
is_sha256 = False
replace_regex = re.compile(r"\"[a-zA-Z0-9\.]+\"")
checksum_regex = re.compile(r"[a-fA-F0-9]{64}")
for line in fileinput.input(cask_file, inplace=True):
    stripped_line = line.strip()
    if has_version and has_arm_hash and has_intel_hash:
        print(line, end="")
        continue
    if stripped_line.startswith("version"):
        has_version = True
        print(replace_regex.sub(f'"{latest_version}"', line), end="")
    elif stripped_line.startswith("sha256") or is_sha256:
        is_sha256 = True
        if checksum_regex.search(line):
            if "arm" in line:
                print(replace_regex.sub(f'"{arm_hash}"', line), end="")
                has_arm_hash = True
                pass
            elif "intel" in line:
                print(replace_regex.sub(f'"{intel_hash}"', line), end="")
                has_intel_hash = True
                pass
        else:
            is_sha256 = False
    else:
        print(line, end="")
