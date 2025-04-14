#! /usr/bin/env python3
import sys

try:
    import tomlkit
except ImportError as e:
    print(
        "tomlkit not found. Please make sure to install the package.\n"
        "If it is already installed, make sure that it is included in the search path."
    )
    raise e


def update_pixi_version(version):
    with open("pixi.toml") as f:
        doc = tomlkit.load(f)
    possible_keys = {"project", "workspace"}
    keys = possible_keys.intersection(set(doc.keys()))
    keys = [key for key in keys if "version" in doc[key]]
    if len(keys) == 0:
        print("pixi.toml doesn't contain [project.version] or [workpace.version] keys")
        return
    for key in keys:
        doc[key]["version"] = version
    with open("pixi.toml", "w") as f:
        tomlkit.dump(doc, f)


if __name__ == "__main__":
    if len(sys.argv) == 2:
        update_pixi_version(sys.argv[1])
    else:
        print("you must provide the version as argument.")
        exit(1)
