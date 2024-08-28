# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# EC2 Instance Resource
resource "aws_instance" "terraform_instance" {
  ami             = "ami-066784287e358dad1"  # Use the preferred AMI
  instance_type   = "t2.micro"
  key_name        = "aws-prod"  # Existing key pair name
  security_groups = ["default"]  # Use the default security group

  # User data script to install Docker and run a container
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker pull devopsike123/devospike:tag123
    sudo docker run -p 80:8080 devopsike123/devospike:tag123
  EOF

  # Remote exec provisioner for Docker installation and container run
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo docker pull devopsike123/devospike:tag123",
      "sudo docker run -p 80:8080 devopsike123/devospike:tag123"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"  # Update according to your AMI
      private_key = file("~/Downloads/aws-prod.pem")  # Path to your private key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "terraform-docker-instance"
  }
}

# Output the EC2 instance's public IP
output "instance_ip" {
  value = aws_instance.terraform_instance.public_ip
}
