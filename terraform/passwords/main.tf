provider "aws" {
  region = "ca-central-1"
}

variable "something" {
  default = "something"
}

#generating password
resource "random_string" "password" {
  length           = 16 
  special          = true #special sharacters - !@#$%&*()-_=+[]{}<>:?
  override_special = "/@£$" #собственный список специальных символов (некоторый софт не допускает использование некоторых символов, поэтому определяем свои)
  keepers = {
    keeper1 = var.something #позволяет сменить пароль, меняется только в том случае если меняется значение в var.something
  }
}
#store pass
resource "aws_ssm_parameter" "password" {
  name = "/prod/mysql"
  description = ""
  type = "SecureString"
  value = random_string.password.result
}
#take pass
data "aws_ssm_parameter" "my_pass" {
  name = "/prod/mysql" #указываем от куда берем сгенерированный пароль
  depends_on = [ aws_ssm_parameter.password ]
}

#use pass on RDS instance (DB)
resource "aws_db_instance" "default" {
  identifier = "prod_rds"
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = aws_ssm_parameter.password.value
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  apply_immediately    = true
}
