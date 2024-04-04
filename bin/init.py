#!venv/bin/python3
import argparse, boto3, subprocess, os

account = None
region = None

basepath = os.getcwd()
client = boto3.client("sts")


parser = argparse.ArgumentParser()
parser.add_argument(
    "--account",
    help="Account Override",
    default=client.get_caller_identity()["Account"],
)
parser.add_argument("--region", help="Region Override", default=client.meta.region_name)
parser.add_argument("path", help="Path Override", default=basepath)
args = parser.parse_args()

config = "/".join([basepath, "config"])
path = "/".join([basepath, args.path])


if os.path.exists(etc) and os.path.exists(path):
    # symlink the provider file in etc to the path, FIXME: use relative path
    provider = ".".join(["provider", args.region, "tf"])
    provider = "/".join([etc, provider])
    try:
        os.symlink(provider, "/".join([path, "provider.tf"]))
    except FileExistsError:
        print("Provider file already exists")

    # delete the .terraform directory if it exists
    terraform = "/".join([path, ".terraform"])
    os.system("rm -rf {}".format(terraform))

    # delete the .terraform.lock.hcl file if it exists
    lock = "/".join([path, ".terraform.lock.hcl"])
    os.system("rm -rf {}".format(lock))

    backend_key = "/".join([args.path, "terraform.tfstate"])
    backend_key = backend_key.replace("//", "/")
    backend_bucket = "-".join(["terraform-state", args.region, args.account])

    # run terraform init from the path
    tf_init = [
        "terraform",
        f"-chdir={path}",
        "init",
        f"-backend-config=key={backend_key}",
        f"-backend-config=bucket={backend_bucket}",
        f"-backend-config=region={args.region}",
    ]
    print(" ".join(tf_init))
    proc = subprocess.run(tf_init)
