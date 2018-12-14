output "IP-nodeA" {
  value = "${aws_instance.nodeA.public_ip}"
}

output "IP-nodeB" {
  value = "${aws_instance.nodeB.public_ip}"
}
