provider "aws" {
  region = ""
}

terraform { # указываем что храним tf.state файл в s3 bucket
  backend "s3" {
    bucket = "tfstate_store" # для 1 проекта используется 1 бакет
    key = "dev/network/terraform.tfstate" # путь к файлу (задаем сами)
    region = "us-east-1"
  }
}

variable "env" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "1.0.0.0/24",
    "2.9.9.0/24"
  ]
}

data "aws_availability_zones" "zones_available" {}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env} - VPC"
  }
}

#для хранения tf.state файла удаленно используется s3bucket (в aws) 
#resource "aws_s3_bucket" "tfstate_store" {}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env} - igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.zones_available.name[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env} - public - ${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id = [element(aws_subnet.public_subnets[*].id, count.index)]
}

#ПРИ ИСПОЛЬЗОВАНИИ УДАЛЕННОГО TFSTATE КРАЙНЕ ВАЖНО ИСПОЛЬЗОВАТЬ АУТПУТЫ - ЕДИНСТВЕННЫЙ СПОСОБ ПОЛУЧИТЬ ДАННЫЕ О ВАШИХ РЕСУРСАХ ДРУГИМ ИНЖЕНЕРАМ
#outputs должен быть в другом файле

output "vpc_id" {
  value = data.aws_vpc.main.id
}
output "vpc_cidr" {
  value = data.aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = data.aws_subnet.public_subnets[*].id
}
