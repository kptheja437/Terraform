resource "aws_vpc" "main" {
  #create vpc

    cidr_block = "192.168.0.0/16"
    instance_tenancy = "default"
    tags = {
      Name = "Nav_terra_vpc"
    }
}


#create IGW
resource "aws_internet_gateway" "igw" {
  #create internet gateway
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Nav_terra_igw"
  }
}


#create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "Nav_terra_public_subnet"
    }
}    




#create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "Nav_terra_private_subnet"
    }

}    

#create route table
resource "aws_route_table" "pub_rt" {     
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "Nav_terra_pub_rt"
    }

}    

#create private route table
resource "aws_route_table" "priv_rt" {     
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Nav_terra_priv_rt"
  }
}

#create public route table association
resource "aws_route_table_association" "pub_rta" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

#create private route table association
resource "aws_route_table_association" "priv_rta" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.priv_rt.id
}


# allocate elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Nav_terra_nat_eip"
  }
}

#create NAT gateway
resource "aws_nat_gateway" "nat_gw" {     
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "Nav_terra_nat_gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# create private route to NAT gateway
resource "aws_route" "priv_rt_nat" {     
  route_table_id = aws_route_table.priv_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}