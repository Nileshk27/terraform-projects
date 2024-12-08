terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tr-vpc"
  }
}

resource "aws_subnet" "my_subnet-1" {
 vpc_id = aws_vpc.myVPC.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
 
 tags = {
   Name = "tr-subnet"
 }

}

resource "aws_security_group" "my_security_group" {
  name = "tr-SG"
  description = "Security group for SSH and HTTP access."
  vpc_id = aws_vpc.myVPC.id

 ingress {
  description = "Allow SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

  ingress {
  description = "Allow HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }


 egress {
  description = "Allow all outbound traffic"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

  tags = {
    Name = "tr-SG"
  }
}

resource "aws_internet_gateway" "myIG" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "My_InternetGateway"
  }
}

resource "aws_route_table" "tr-aws_route_table" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIG.id
  }

  tags = {
    Name = "tr-route_table"
  }
}

resource "aws_route_table_association" "tr-awsroute_table_association" {
  subnet_id = aws_subnet.my_subnet-1.id
  route_table_id = aws_route_table.tr-aws_route_table.id

}



resource "aws_instance" "sample" {
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_id = aws_subnet.my_subnet-1.id
  key_name = "AWS_Prac"
  associate_public_ip_address = true

  tags = {
    Name = "my-tf-instance"
  }
}

output "instance_public_ip" {
 value = aws_instance.sample.public_ip 
}