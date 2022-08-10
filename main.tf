
provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "public" {
  description = "Allow limited inbound external traffic"
  vpc_id      = "vpc-0f76f954b13dab293"
  name        = var.security_group_name
  tags = {
    Name        = var.security_group_name
    Role        = "public"
    Project     = "cloudcasts.io"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.public.id
}
resource "aws_security_group_rule" "public_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_eighty" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}


##########
## Internet Gateway
#resource "aws_internet_gateway" "terra_igw" {
#  vpc_id = "vpc-0f76f954b13dab293"
#  tags = {
#    Name = "terramain"
#  }
#}

## Route table: attach Internet Gateway 
#resource "aws_route_table" "public_rt" {
#  vpc_id = "vpc-0f76f954b13dab293"
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.terra_igw.id
#  }
#  tags = {
#    Name = "publicRouteTable"
#  }
#}
#######

resource "aws_subnet" "terraform-subnet_1" {
  vpc_id            = "vpc-0f76f954b13dab293"
  cidr_block        = var.subnet1_cidr_block
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet1_name
  }
}

resource "aws_subnet" "terraform-subnet_2" {
  vpc_id            = "vpc-0f76f954b13dab293"
  cidr_block        = var.subnet2_cidr_block
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet2_name
  }
}



# Route table association with public subnets
resource "aws_route_table_association" "a" {
  #count = length(var.subnets_cidr)
  subnet_id      = "${aws_subnet.terraform-subnet_1.id}"
  route_table_id = "rtb-0a5023b60c8260264"
  #aws_route_table.public_rt.id
}
resource "aws_route_table_association" "a1" {
  #count = length(var.subnets_cidr)
  subnet_id      = "${aws_subnet.terraform-subnet_2.id}"
  route_table_id = "rtb-0a5023b60c8260264"
  #aws_route_table.public_rt.id
}



#resource "aws_ebs_volume" "example" {
#  availability_zone = "us-east-2a"
#  size              = 40

#  tags = {
#    Name = "terraform-ebs"
#  }
#}


resource "aws_instance" "this" {

  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id              = aws_subnet.terraform-subnet_1.id
  #ebs_optimized          = aws_ebs_volume.example.id
  
  
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.instance_volume_size
  }
  
  tags = {
    "Name"      = var.instance_name
    "Terraform" = "true"
  }
}



resource "aws_route53_record" "dom" {
  zone_id = "Z3H9K4B2UE4C37"
  name    = var.DNS_name
  type    =  "CNAME"
  ttl     = 60
  records = [aws_lb.sample_lb.dns_name]
  #"A"
  ###ttl     = "300"
  #records = "${aws_instance.this.*.public_ip}"
  
  #alias {
  #  name                   = "${aws_lb.sample_lb.dns_name}"
  #  zone_id                = aws_lb.sample_lb.zone_id
  #  evaluate_target_health = true
  #}
  
}


##cert creation
resource "aws_acm_certificate" "cert" {
  domain_name       = var.DNS_name
  validation_method = "DNS"

  tags = {
    Environment = "saas-test"
  }

  lifecycle {
    create_before_destroy = true
  }
}


##############################################

#data "aws_route53_zone" "cert" {
#  name         = "saasoe.ovaledge.net"
#  private_zone = false
#}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = "Z3H9K4B2UE4C37"
  #data.aws_route53_zone.cert.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}
##############################################
#####################################
#resource "aws_acm_certificate_validation" "example" {
#  certificate_arn = aws_acm_certificate.cert.arn
#}
#########################################

resource "aws_lb_target_group" "sample_tg" {
   #for_each           = var.alb_names
   #name               = each.value
   name                = var.target_group_name
   target_type        = "instance"
   port               = 8080
   protocol           = "HTTP"
   vpc_id             = "vpc-0f76f954b13dab293"
   #"vpc-0f76f954b13dab293"
   health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
  
}

resource "aws_lb" "sample_lb" {
    #for_each           = var.alb_names
    #name               = each.value
	name                = var.load_balancer_name
    internal           = false
    load_balancer_type = "application" 
    security_groups    = ["${aws_security_group.public.id}"]
    subnets            = ["${aws_subnet.terraform-subnet_1.id}","${aws_subnet.terraform-subnet_2.id}"]
    enable_cross_zone_load_balancing = "true"
    tags = {
         Environment = "Production"
         Role        = "Sample-Application"
    }
}

resource "aws_lb_target_group_attachment" "tg_attachment_test" {
    target_group_arn = aws_lb_target_group.sample_tg.arn
    target_id        = "${element(aws_instance.this.*.id, 0)}"
	#"aws_instance.this.*.id"
	###"${element(split(",", join(",", aws_instance.this.*.id)), count.index)}"
    port             = 8080
}


# Listener rule for HTTP traffic on each of the ALBs


resource "aws_lb_listener" "lb_listener_https" {
   load_balancer_arn    = aws_lb.sample_lb.id
   port                 = "443"
   protocol             = "HTTPS"
   certificate_arn      = aws_acm_certificate.cert.arn
   default_action {
    target_group_arn = aws_lb_target_group.sample_tg.id
    type             = "forward"	
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.sample_lb.id
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
	  
      status_code = "HTTP_301"
    }
  }
}


###################WAF

resource "aws_wafregional_ipset" "ipset" {
  name = var.WAF_ipset_name

  ip_set_descriptor {
    type  = "IPV4"
    value = var.WAF_ip_address_to_allow_access
  }
}

resource "aws_wafregional_rule" "foo" {
  name        = var.WAF_rule_name
  metric_name = var.WAF_rule_name

  predicate {
    data_id = aws_wafregional_ipset.ipset.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "foo" {
  name        = var.WAF_web_acl_name
  metric_name = var.WAF_web_acl_name

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.foo.id
  }
}

resource "aws_wafregional_web_acl_association" "foo" {
  resource_arn = aws_lb.sample_lb.id
  web_acl_id   = aws_wafregional_web_acl.foo.id
}




