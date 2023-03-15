variable "myregion"{
type = string
}

variable "myami"{
type = string
}

variable "mypublickey"{
type = string
}

variable "cicd_count"{
type = string
}

################ Authentication ##########33
provider "aws" {
    region = var.myregion
}

#########  Networking ##############
# Step 1
resource "aws_vpc" "jenkinsvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "jenkinsvpc"
    }

}

# Step 2
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.jenkinsvpc.id
  tags = {
    Name = "myigw"
  }
}
 
# Step 3
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.jenkinsvpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "mysubnet"
  }
}

# Step 4
resource "aws_route_table" "myrtb" {
vpc_id = "${aws_vpc.jenkinsvpc.id}"
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = "${aws_internet_gateway.myigw.id}"
 }
 tags = {
 Name = "myrtb"
 }
}

# Step 5
resource "aws_route_table_association" "myrtba" {
 subnet_id = aws_subnet.mysubnet.id
 route_table_id = aws_route_table.myrtb.id
}

########### Security ################
# Step 1
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "mysg"
  }
}

# Step 2
resource "aws_key_pair" "mykp" {
  key_name   = "mykp"
  public_key = var.mypublickey
}

###############  Computing ############
resource "aws_instance" "cicd" {
  count = var.cicd_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "mykp"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.micro"
  tags = {
    Name = "cicd-server"
  }
}



 
