variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "instance_name" {
  description = "Name of instances"
  type        = string
  default     = "OvalEdge_Server_terra_latest"
}

variable "instance_volume_size" {
  description = "volume size of instances"
  type        = number
  default     = 60
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.large"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = "ovaledgechakri"
}

variable "DNS_name" {
  description = "Name of domain you want to take from aws"
  type        = string
  default     = "saastest.ovaledge.net"
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = "ami-03a0c45ebc70f98ea"
}

variable "security_group_name" {
  description = "name of the security group"
  type        = string
  default     = "terraform_sec"
}

variable "subnet1_name" {
  description = "name of the subnet1"
  type        = string
  default     = "terraform_sub1"
}

variable "subnet1_cidr_block" {
  description = "cidr block of the subnet1"
  type        = string
  default     = "10.0.30.0/24"
}

variable "subnet2_name" {
  description = "name of the subnet2"
  type        = string
  default     = "terraform_sub2"
}

variable "subnet2_cidr_block" {
  description = "cidr block of the subnet2"
  type        = string
  default     = "10.0.40.0/24"
}


variable "target_group_name" {
  description = "name of the target group"
  type        = string
  default     = "terraformtarget"
}

variable "load_balancer_name" {
  description = "name of the load balancer"
  type        = string
  default     = "terraformloadbalancer"
}

variable "WAF_ip_address_to_allow_access" {
  description = "ip address range to allow access to ovaledge app"
  type        = string
  default     = "49.37.131.46/32"
}

variable "WAF_rule_name" {
  description = "name of the WAF rule"
  type        = string
  default     = "terraform_tfWAFRule"
}

variable "WAF_ipset_name" {
  description = "name of the WAF ipset"
  type        = string
  default     = "terraform_tfIPSet"
}

variable "WAF_web_acl_name" {
  description = "name of the WAF web acl"
  type        = string
  default     = "terraform_foo"
}

variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "8080"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}




