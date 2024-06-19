provider "aws" {
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:123456789:role/Admin"
    session_name = "terraform session"
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "USA"
}

provider "aws" {
  region = "eu-central-1"
  alias = "GER"
}


resource "aws_instance" "server" {
  ami = ""
  instance_type = "t3.micro"
  tags = {
    Name = "server"
    Owner = "Denis Prokopev"
  } 
}

resource "aws_instance" "USAserver" {
  provider = aws.USA
  ami = ""
  instance_type = "t3.micro"
  tags = {
    Name = "server"
    Owner = "Denis Prokopev"
  } 
}

resource "aws_instance" "GERserver" {
  provider = aws.GER
  ami = ""
  instance_type = "t3.micro"
  tags = {
    Name = "server"
    Owner = "Denis Prokopev"
  }
}

