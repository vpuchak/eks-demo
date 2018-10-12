data "aws_security_group" "worker" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.env}-eks-worker"
  }
}

data "aws_security_group" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "${var.env} Security Group"
  }
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_iam_instance_profile" "worker" {
  name = "${var.env}-worker"
}

locals {
  worker-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_key_pair" "main" {
  key_name   = "eks-${var.env}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "worker" {
  count                       = "${var.count}"
  ami                         = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  vpc_security_group_ids      = [ "${data.aws_security_group.main.id}", "${data.aws_security_group.worker.id}" ]
  associate_public_ip_address = true
  iam_instance_profile = "${data.aws_iam_instance_profile.worker.name}"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }
  user_data_base64            = "${base64encode(local.worker-userdata)}"
  key_name = "${aws_key_pair.main.key_name}"
  tags {
    Name = "${var.env} - Worker"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}