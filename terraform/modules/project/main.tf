
#USING MODULES

provider "aws" {
  region = ""
}

module "vpc-default" { #использует параметры которые уже прописаны в модуле по умолчанию
  source = "../aws_network" # .. - переход на папку выше
}

module "vpc-default" { #посылаем нужные нам параметры
  source = "../aws_network"
# source = "git@hub.com:user/pepo.git//aws_network" # использование удаленного модуля
  env = "development"
  vpc_cidr = "11.0.0.0/24"
  public_subnets = ["10.100.0.0/24", "10.200.0.0/24"]
  private_subnets = ["10.100.1.0/24", "10.200.2.0/24"]
}

module "vpc-default" { #посылаем нужные нам параметры
  source = "../aws_network"
  env = "prod"
  vpc_cidr = "15.0.0.0/24"
  public_subnets = ["15.100.0.0/24", "15.200.0.0/24"]
  private_subnets = ["15.100.1.0/24", "15.200.2.0/24"]
}

#в качестве outputs мы можем использовать только те, которые прописаны в модуле
