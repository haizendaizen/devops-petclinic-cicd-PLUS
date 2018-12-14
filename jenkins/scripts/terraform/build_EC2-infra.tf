provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "nodeA" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  key_name      = "MyKeyPair"
  security_groups = [
    "launch-wizard-5",
    "Web Browser access"
  ]

  tags {
    Name = "nodeA"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.nodeA.public_ip} > ../../../hosts"
  }
}

resource "aws_instance" "nodeB" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  key_name      = "MyKeyPair"
  security_groups = [
    "launch-wizard-5",
    "Web Browser access"
  ]

  tags {
    Name = "nodeB"
  }

  # Tells Terraform that this EC2 instance must be created only after the
  # nodeA has been created.
  depends_on = ["aws_instance.nodeA"]

  provisioner "local-exec" {
    command = "echo ${aws_instance.nodeB.public_ip} >> ../../../hosts"
  }
}

resource "aws_instance" "webserver" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  key_name      = "MyKeyPair"
  security_groups = [
    "launch-wizard-5",
    "Web Browser access"
  ]

  tags {
    Name = "NGINX"
  }

  depends_on = ["aws_instance.nodeB"]

  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver.public_ip} > ../../../httpd"
  }
}
