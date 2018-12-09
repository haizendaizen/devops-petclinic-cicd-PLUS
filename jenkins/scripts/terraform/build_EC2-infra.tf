provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "nodeA" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.nodeA.public_ip} > hosts"
  }
}

resource "aws_instance" "nodeB" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.nodeB.public_ip} >> hosts"
  }
}
