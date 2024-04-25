#!/usr/bin/env python

import argparse
from pathlib import Path


def parse():
    parser = argparse.ArgumentParser(
        description="Blitz - A simple static site generator"
    )
    parser.add_argument(
        "command", help="The command to run", choices=["init"], default="init"
    )
    parser.add_argument("path", help="The path to the site", nargs="?")
    args = parser.parse_args()
    match args.command:
        case "init":
            if args.path and Path(args.path).is_dir():
                path = Path(args.path).resolve()
                stack = path.name
                path = path.parent
                region = path.name
                path = path.parent
                environment = path.name
                path = path.parent
                terraform = path.name
                path = path.parent
                basepath = path.parent
                print(stack, region, environment, terraform, basepath)

                # parts = PurePath(path).parts
                # stack = parts[-1]
                # region = parts[-2]
                # environment = parts[-3]
                # terraform = parts[-4]
                # base = parts[0:-4]
                # print(parts)
                # print(stack, region, environment, terraform, base)
            else:
                print("no path provided")
                Path.cwd().joinpath("site").mkdir(exist_ok=True)
        case _:
            parser.print_help()


if __name__ == "__main__":
    parse()
