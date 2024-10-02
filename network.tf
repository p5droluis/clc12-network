#CRIANDO A VPC
variable "vpc_name" {
    type = string 
    default = "vpc_clc12_terraform"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}
#CRIANDO A SUBNET PUBLICA
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf_public_subnet_1a"
  }
}
#CRIANDO A SUBNET PRIVADA
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf_private_subnet_1a"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf_igw"
  }
}
#CRIANDO A TABELA DE ROTA
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf_public_rt"
  }
}
#ASSOCIANDO A TABELA DE ROTAS PUBLICA A SUBNET PUPLICA
resource "aws_route_table_association" "public_rt_associate" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
#CRIANDO UM IP PUBLICO PARA O NATGW
resource "aws_eip" "nat_gw_ip" {
  domain   = "vpc"
}
#CRIANDO O NATEGW ASSOCIADO AO IP PUBLICO COM DEPENDENCIA DA CRIAÇÃO DO InternetGW
resource "aws_nat_gateway" "natgw_1a" {
  allocation_id = aws_eip.nat_gw_ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "tf_natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
  }
  #CRIANDO A TABELA DE ROTA PRIVADA
  
  #CRIANDO A TABELA DE ROTA
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw_1a.id
  }

  tags = {
    Name = "tf_private_rt"
  }
  }
  #ASSOCIANDO A TABELA DE ROTAS PRIVADA A SUBNET PRIVADA
resource "aws_route_table_association" "private_rt_associate" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
  }