provider "aws" {
  region     = "us-east-2"
  access_key = "AKIA25TFYQAKOIEVUKV5"
  secret_key = "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"
}

resource "aws_vpc" "vpc" {
  cidr_block           ="192.168.0.0/16"
  instance_tenancy     ="default"
  enable_dns_support   =true
  enable_dns_hostnames =true

  tags={
      Name="demo_vpc"
  }
}


resource "aws_subnet" "pub_sub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "pub_sub"
  }
}


resource "aws_subnet" "pri_sub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "Pri_sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "eip" {
   vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pri_sub.id

  tags = {
    Name = "NAT_GATEWAY"
  }

}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  
  tags = {
    Name = "custom"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  
  tags = {
    Name = "main"
  }

}

resource "aws_route_table_association" "as_1" {
  subnet_id      = aws_subnet.pub_sub.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "as_2" {
 subnet_id      = aws_subnet.pri_sub.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_security_group" "sg" {
  name        = "first_sg"
  
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "first_sg"
  }
}
