import argparse, sys
from pathlib import Path


class parse(object):
    def __init__(self):
        parser = argparse.ArgumentParser(
            description="bps infra tool",
            usage="""bps <command> [<args>]
The most commonly used bps commands are:
   init       Download objects and refs from another repository
   scan       Run static code analysis of the terraform code
""",
        )
        parser.add_argument("command", help="Subcommand to run")
        # parse_args defaults to [1:] for args, but you need to
        # exclude the rest of the args too, or validation will fail
        args = parser.parse_args(sys.argv[1:2])
        if not hasattr(self, args.command):
            print("Unrecognized command")
            parser.print_help()
            exit(1)
        # use dispatch pattern to invoke method with same name
        getattr(self, args.command)()

    def init(self):
        init.dispatch()

    # def scan(self):
    #     scan.dispatch()


class init(object):
    @staticmethod
    def dispatch():
        parser = argparse.ArgumentParser(description="Initialise the Terraform Stack")
        parser.add_argument("path", help="Path to the Terraform Stack")
        args = parser.parse_args(sys.argv[2:])
        print("Running bps init, amend=%s" % args.path)
        print(Path.cwd())
        print(Path(args.path).resolve())
        print(Path("foo").resolve())


class scan(object):
    @staticmethod
    def dispatch():
        pass
        # parser = argparse.ArgumentParser(
        #     description="Download objects and refs from another repository"
        # )
        # parser.add_argument("repository")
        # args = parser.parse_args(sys.argv[2:])
        # print("Running bps scan, repository=%s" % args.repository)
