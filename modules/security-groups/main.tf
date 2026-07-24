############################################
# Security Group
############################################

resource "aws_security_group" "ssm" {
  name        = "${var.naming_prefix}-SSM-SG"
  description = "Allows HTTPS (443) between the SSM EC2 instance and the SSM VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-SSM-SG"
  })
}

# Inbound HTTPS from resources that share this security group
# (EC2 instance <-> VPC endpoints)
resource "aws_security_group_rule" "ingress_https_self" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ssm.id
  self              = true
  description       = "HTTPS inbound from instances/endpoints in the same SG"
}

# All outbound traffic allowed (needed for EC2 -> endpoints and endpoint responses)
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssm.id
  description       = "Allow all outbound traffic"
}
