############################################
# VPC outputs
############################################

output "vpc_id" {
  description = "ID of the VPC-SSM VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "private_subnet_availability_zone" {
  description = "Availability zone used for the private subnet"
  value       = aws_subnet.private.availability_zone
}

output "private_route_table_id" {
  description = "ID of the private route table (local route only, no NAT/IGW)"
  value       = aws_route_table.private.id
}

############################################
# VPC Endpoints outputs
############################################

output "vpc_endpoint_ssm" {
  description = "VPC endpoint ID for SSM"
  value       = aws_vpc_endpoint.ssm["ssm"].id
}

output "vpc_endpoint_ssmmessages" {
  description = "VPC endpoint ID for SSM Messages"
  value       = aws_vpc_endpoint.ssm["ssmmessages"].id
}

output "vpc_endpoint_ec2messages" {
  description = "VPC endpoint ID for EC2 Messages"
  value       = aws_vpc_endpoint.ssm["ec2messages"].id
}

output "vpc_endpoint_ids" {
  description = "Map of endpoint service key to its VPC endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.ssm : k => v.id }
}

output "vpc_endpoint_dns_entries" {
  description = "Map of endpoint service key to its private DNS entries"
  value       = { for k, v in aws_vpc_endpoint.ssm : k => v.dns_entry }
}

output "vpc_endpoint_network_interface_ids" {
  description = "Map of endpoint service key to its ENI IDs in the private subnet"
  value       = { for k, v in aws_vpc_endpoint.ssm : k => v.network_interface_ids }
}
