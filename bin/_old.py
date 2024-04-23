#!/usr/bin/env python
import argparse, boto3, subprocess, os

account = None
region = None

basepath = os.getcwd()

parser = argparse.ArgumentParser()
client = boto3.client("sts")
account = client.get_caller_identity()["Account"]
parser.add_argument("--account", help="Account Override", default=account)
parser.add_argument(
    "--region", help="Region Override", default="eu-west-1"
)  # client.meta.region_name)
parser.add_argument("path", help="Path Override", default=basepath)
args = parser.parse_args()

config = "/".join([basepath, "config"])
path = "/".join([basepath, args.path])


if os.path.exists(config) and os.path.exists(path):

    backend_key = "/".join([args.path, "terraform.tfstate"])
    backend_key = backend_key.replace("//", "/").replace("terraform/", "")
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
