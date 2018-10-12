provider "aws" {
  region = "${var.region}"
}

data "aws_vpc" "main" {
  tags {
    Name = "${var.env} - Main"
    Env  = "${var.env}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.env} - public"
  }
}

data "aws_security_group" "cluster" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.env} - cluster"
  }
}

data "aws_iam_role" "cluster" {
  name = "eks-${var.env}"
}

resource "aws_eks_cluster" "main" {
  name            = "${var.cluster-name}"
  role_arn        = "${data.aws_iam_role.cluster.arn}"

  vpc_config {
    security_group_ids = ["${data.aws_security_group.cluster.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.public.ids}"]
  }
}