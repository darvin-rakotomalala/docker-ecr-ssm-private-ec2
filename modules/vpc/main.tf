############################################
# VPC configuration
############################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-VPC-SSM"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.data_az_available_names

  # Private subnet: instances never receive a public IP
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-private-subnet"
    Tier = "private"
  })
}

# Route table with only the default local route (no 0.0.0.0/0 route,
# since there is no NAT gateway or Internet Gateway in this design).
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

############################################
# VPC Endpoints for Private Instances (no NAT gateway)
############################################

locals {
  # Maps each endpoint service key to its display name, per the spec
  vpc_endpoint_names = {
    "ssm"         = "VPCE-SSM"
    "ssmmessages" = "VPCE-SSM-MESSAGES"
    "ec2messages" = "VPCE-EC2-MESSAGES"
  }
  # SSM-related VPC endpoint services to create (Interface type)
  services = {
    "ec2messages" : {
      "name" : "com.amazonaws.${var.primary_region}.ec2messages"
    },
    "ssm" : {
      "name" : "com.amazonaws.${var.primary_region}.ssm"
    },
    "ssmmessages" : {
      "name" : "com.amazonaws.${var.primary_region}.ssmmessages"
    }
  }
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = local.services

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.name
  vpc_endpoint_type   = "Interface"
  ip_address_type     = "ipv4"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = var.ssm_security_group_id
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = local.vpc_endpoint_names[each.key]
  })
}
