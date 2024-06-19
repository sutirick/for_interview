provider "aws" {
  region = "ca-central-1"
}
#===========================================================================================================================================

terraform { # указываем что храним tf.state файл в s3 bucket
  backend "s3" {
    bucket = "tfstate_store" # для 1 проекта используется 1 бакет
    key = "dev/servers/terraform.tfstate" # путь к файлу (задаем сами)
    region = "us-east-1"
  }
}
#===========================================================================================================================================

data "terraform_remote_state" "network" {
  backend = "s3"
  config = { #прописываем конфиг бакета из которого берем инфу
    bucket = "tfstate_store"
    key = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}
#ТАКИМ ОБРАЗОМ МЫ ПОЛУЧИЛИ ВСЕ OUTPUTS, КОТОРЫЕ БЫЛИ СДЕЛАНЫ ДРУГИМ ИНЖЕНЕРОМ ИЗ ДРУГОЙ ЧАСТИ ОБЩЕГО ПРОЕКТА

data "aws_ami" "latest_linux" {
  owners = [ "amazon" ]
  most_recent = true
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
  }
}
#===========================================================================================================================================

resource "aws_security_group" "web_sg" {
  name = "SecGr"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  }
  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = [data.terraform_remote_state.network.vpc_cidr]
  }
  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Security Group"
  }
}
#===========================================================================================================================================

resource "aws_instance" "server" {
  ami = data.aws_ami.latest_linux.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  #user_data = 
}
#===========================================================================================================================================

output "info_from_remotestate_network" {
  value = data.terraform_remote_state.network
}

output "aws_security_group_id" {
  value = data.aws_security_group.id
}

output "public_ip_server" {
  value = data.aws_instance.server.public_ip
}