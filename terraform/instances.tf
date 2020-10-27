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

# Configure User_data
data "template_file" "user_data" {
  template = file("./scripts/install-prereqs.txt")
}

# Create and bootstrap EC2 in us-east-1
resource "aws_instance" "k8s-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.k8s-master-instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8s-core-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  user_data                   = data.template_file.user_data.rendered

  # tags used by ansible for dynamic inventory resolution
  tags = {
    Name = "k8s-master",
    lab  = "storage",
    type = "k8s"
  }

  # not needed as all in the same VPC right now
  #depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

  # uses dynamic inventory but also executes using local invocation and so requires python 
  # and anisble installed and available from Terraform
  #provisioner "local-exec" {
  #  command = <<EOF
  #aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id}
  #ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/k8s-master-sample.yml
  #EOF
  #  }

  # remote provisioner - executes over on the target node
  # provisioner "remote-exec" {
  #   when = create
  #   inline = [ "echo 'Executing remotely'" ]
  #   connection {
  #     type = "ssh"
  #     user = "ec2-user"
  #     privat_key = file("~/.ssh/id_rsa")
  #     host = self.public_ip
  #   }
}

# associate EIP with k8s-master
resource "aws_eip" "k8s_eip" {
  provider = aws.region-master
  instance = aws_instance.k8s-master.id
  vpc      = true
  tags = {
    lab  = "storage"
    type = "k8s"
    Name = "eip-k8s-master"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_eip_association" "k8s_eip_assoc" {
  provider      = aws.region-master
  instance_id   = aws_instance.k8s-master.id
  allocation_id = aws_eip.k8s_eip.id
}


# create EC2 k8s-worker in us-east-1
resource "aws_instance" "k8s-worker" {
  provider                    = aws.region-master
  count                       = var.k8s-workers-count
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k8s-core-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  user_data                   = data.template_file.user_data.rendered

  tags = {
    Name = join("_", ["k8s-worker", count.index + 1]),
    lab  = "storage",
    type = "k8s"
  }

  depends_on = [aws_instance.k8s-master]
}
