resource "aws_instance" "this" {

  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id              = aws_subnet.terraform-subnet_1.id

  ecs_associate_public_ip_address = "true"

  #ebs_optimized          = aws_ebs_volume.example.id
  
  
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.instance_volume_size
    encrypted     = true
  }
  monitoring = true

  #root_block_device {
  #encrypted     = true
  #}
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    "Name"      = var.instance_name
    "Terraform" = "true"
  }
}