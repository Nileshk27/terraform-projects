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

resource "aws_instance" "sample" {
  ami = "ami-0453ec754f44f9a4a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet-1.id
  key_name = "AWS_Prac"
}