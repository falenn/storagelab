# Get Linux AMI using SSM parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
# Get Linux AMI using SSM parameter endpoint in us-west-2
data "aws_ssm_parameter" "linuxAmiOregon" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#create key-pair for SSH access into EC2 instance in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "storagelab"
  public_key = file("~/.ssh/id_rsa.pub")
}

#create key-pair for SSH access into EC2 instance in us-west-2
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "storagelab"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create and bootstrap EC2 in us-east-1
resource "aws_instance" "k8s-master" {
  provider = aws.region-master
  ami = data.aws_ssm_parameter.linuxAmi.value
  instance_type = var.instance-type
  key_name = aws_key_par.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.k8s-core-sg.id]
  subnet_id = aws_subnet.subnet_1.id
  
  tags = {
    Name = "k8s-master",
    lab = "storage"
  }
  
  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
}


