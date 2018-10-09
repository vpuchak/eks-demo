provider "aws" {
  region = "${var.region}"
}

data "aws_vpc" "main" {
  tags {
    Name = "${var.env} - Main"
    Env  = "${var.env}"
  }
}

data "aws_subnet" "public" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.env} - public"
  }
}

data "aws_security_group" "cluster" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "eks-${var.env}-sg"
  }
}

data "aws_iam_role" "cluster" {
  tags {
    name = "eks-${var.env}"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "cats"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_eks_cluster" "main" {
  name            = "${var.cluster-name}"
  role_arn        = "${data.aws_iam_role.cluster.arn}"

  vpc_config {
    security_group_ids = ["${data.aws_security_group.cluster.id}"]
    subnet_ids         = ["${data.aws_subnet.public.*.id}"]
  }
}