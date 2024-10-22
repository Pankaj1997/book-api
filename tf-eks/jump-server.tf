resource "aws_iam_role" "eks_ec2_role" {
  name = "eks-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks_ec2_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks_ec2_role.name
}

resource "aws_iam_policy" "eks_custom_policy" {
  name = "eks-custom-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.eks_ec2_role.name
  policy_arn = aws_iam_policy.eks_custom_policy.arn
}

# IAM Instance Profile for Jump Server
resource "aws_iam_instance_profile" "jump_server_profile" {
  name = "jump-server-profile"
  role =  aws_iam_role.eks_ec2_role.name
}

# Creating KeyPair
resource "aws_key_pair" "deployer" {
  key_name   = "book-deployer-key"
  public_key = file(var.pub_key) # Adjust the path to your public key
}

# Security group to allow inbound SSH access to jump server
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #can be changed to your VPN Outbound IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "book_jump_server" {
  ami           = "ami-0e0e417dfa2028266"
  instance_type = "t3a.micro"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.jump_server_profile.name

  associate_public_ip_address = true

 root_block_device {
    volume_size = 10  # Adjust the size as needed
    volume_type = "standard"  # Adjust the volume type as needed
    encrypted   = true   # Enable encryption
  }

  tags = {
    Name = "book-jump-server"
  }

  depends_on = [
    aws_key_pair.deployer,
    module.vpc,
    aws_security_group.allow_ssh,
    module.eks,
    aws_iam_instance_profile.jump_server_profile
  ]
  # Optional: Ensure the instance is fully running before executing the provisioner
  provisioner "remote-exec" {
    inline = [
      "touch /tmp/lb_ip.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key)  # Path to your private key
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i "${self.public_ip}," book_deploy.yaml --user ec2-user -e "eks_region=${var.region} eks_cluster_name=${var.cluster_name}"
    EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"  # Optional: Disable host key checking for simplicity
    }

    # Ensure this runs only after the instance is created and accessible
    when = create
  }
}

