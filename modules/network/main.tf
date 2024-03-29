# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr["${terraform.workspace}"]
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${terraform.workspace}-${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${terraform.workspace}-${var.project_name}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available" {}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${terraform.workspace}-private_subnet_az-" [count.index]
  }
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${terraform.workspace}-public_subnet_az-"[count.index]
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {
  count      = var.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }

  tags = {
    Name = "${terraform.workspace}-private_route_table"[count.index]
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}





# # create public subnet az1
# resource "aws_subnet" "public_subnet_az1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.public_subnet_az1_cidr["${terraform.workspace}"]
#   availability_zone       = data.aws_availability_zones.availability_zones.names[0]
#   map_public_ip_on_launch = true

#   tags = {
#     "Name" = "${terraform.workspace}-public_subnet_az1"
#   }
# }

# # create public subnet az2
# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.public_subnet_az2_cidr["${terraform.workspace}"]
#   availability_zone       = data.aws_availability_zones.availability_zones.names[1]
#   map_public_ip_on_launch = true

#   tags = {
#     "Name" = "${terraform.workspace}-public_subnet_az2"
#   }
# }

# # create route table and add public route
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.internet_gateway.id
#   }

#   tags = {
#     Name = "${terraform.workspace}-public_route_table"
#   }
# }

# # associate public subnet az1 to "public route table"
# resource "aws_route_table_association" "public_subnet_az1_rta" {
#   subnet_id      = aws_subnet.public_subnet_az1.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# # associate public subnet az2 to "public route table"
# resource "aws_route_table_association" "public_subnet_az2_rta" {
#   subnet_id      = aws_subnet.public_subnet_az2.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# # create private subnet az1
# resource "aws_subnet" "private_subnet_az1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.private_subnet_az1_cidr["${terraform.workspace}"]
#   availability_zone       = data.aws_availability_zones.availability_zones.names[0]
#   map_public_ip_on_launch = false

#   tags = {
#     "Name"                            = "${terraform.workspace}-private_subnet_az1"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/demo"      = "owned"
#   }
# }

# # create private subnet az2
# resource "aws_subnet" "private_subnet_az2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.private_subnet_az2_cidr["${terraform.workspace}"]
#   availability_zone       = data.aws_availability_zones.availability_zones.names[1]
#   map_public_ip_on_launch = false

#   tags = {
#     "Name"                            = "${terraform.workspace}-private_subnet_az2"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/demo"      = "owned"
#   }
# }

# # Create NAT gateway
# resource "aws_eip" "nat" {
#   domain = "vpc"

#   tags = {
#     Name = "nat"
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_subnet_az1.id

#   tags = {
#     Name = "nat"
#   }

#   depends_on = [aws_internet_gateway.internet_gateway]
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "${terraform.workspace}-private_route_table"
#   }
# }

# # associate private subnet az1 to "private route table"
# resource "aws_route_table_association" "private_subnet_az1_rta" {
#   subnet_id      = aws_subnet.private_subnet_az1.id
#   route_table_id = aws_route_table.private_route_table.id
# }

# # associate private subnet az2 to "private route table"
# resource "aws_route_table_association" "private_subnet_az2_rta" {
#   subnet_id      = aws_subnet.private_subnet_az2.id
#   route_table_id = aws_route_table.private_route_table.id
# }