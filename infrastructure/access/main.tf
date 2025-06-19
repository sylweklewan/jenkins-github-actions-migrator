resource "tls_private_key" "tensordock-connect-key" {
  algorithm = "ED25519"
}

resource "local_file" "ec2_private_key" {
  filename        = ".${var.tensordock_key_name}.pem"
  content         = tls_private_key.tensordock-connect-key.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "ec2_public_key" {
  filename        = ".${var.tensordock_key_name}.pub"
  content         = tls_private_key.tensordock-connect-key.public_key_openssh
  file_permission = "0600"
}

