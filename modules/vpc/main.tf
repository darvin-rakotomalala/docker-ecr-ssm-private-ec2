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

############################################
# Internet Gateway (required for NAT to work)
############################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-igw"
  })
}

############################################
# Public subnet (required to host the NAT Gateway)
############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.data_az_available_names
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-public-subnet"
    Tier = "public"
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

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# NAT Gateway (lives in public subnet, used by private subnet)
############################################
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-nat-eip"
  })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-nat-gw"
  })
  depends_on = [aws_internet_gateway.this]
}

# Route table with only the default local route (no 0.0.0.0/0 route,
# since there is no NAT gateway or Internet Gateway in this design).
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-private-rt"
  })
}

############################################
# Update private route table to send internet traffic via NAT
############################################
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
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
