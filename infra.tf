variable "myregion"{
type = string
}

variable "myami"{
type = string
}

variable "mypublickey"{
type = string
}

variable "gunicorn_count"{
type = string
}

variable "jenkins_count"{
type = string
}

variable "artifactory_count"{
type = string
}

variable "haproxy_count"{
type = string
}
variable "sql_count"{
type = string
}

################ Authentication ##########33
provider "aws" {
    region = var.myregion
}

#########  Networking ##############
# Step 1
resource "aws_vpc" "webappvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "webappvpc"
    }

}

# Step 2
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.webappvpc.id
  tags = {
    Name = "myig"
  }
}
 
# Step 3
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.webappvpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "mysubnet"
  }
}

# Step 4
resource "aws_route_table" "myrtb" {
vpc_id = "${aws_vpc.webappvpc.id}"
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = "${aws_internet_gateway.myigw.id}"
 }
 tags = {
 Name = "myrtb"
 }
}

# Step 5
resource "aws_route_table_association" "myrtb" {
 subnet_id = aws_subnet.mysubnet.id
 route_table_id = aws_route_table.myrtb.id
}

########### Security ################
# Step 1
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.webappvpc.id

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
resource "aws_key_pair" "my" {
  key_name   = "my"
  public_key = var.mypublickey
}

###############  Computing ############
resource "aws_instance" "gunicorn_count" {
  count = var.gunicorn_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "my"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.medium"
  tags = {
    Name = "gunicorn_count"
  }
}
resource "aws_instance" "sql_count" {
  count = var.sql_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "my"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.medium"
  tags = {
    Name = "mysql-server"
  }
}


resource "aws_instance" "haproxy_count" {
  count = var.haproxy_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "my"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.micro"
  tags = {
    Name = "haproxy_count"
  }
}
 
resource "aws_instance" "jenkins_count" {
  count = var.jenkins_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "my"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.micro"
  tags = {
    Name = "jenkins_count"
  }
}

resource "aws_instance" "artifactory_count" {
  count = var.artifactory_count
  ami           = var.myami
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "my"
  subnet_id = aws_subnet.mysubnet.id
  instance_type = "t2.medium"
  tags = {
    Name = "artifactory_count"
  }
}
