# Create a VPC
resource "aws_vpc" "aps_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet
resource "aws_subnet" "public" {
    
  vpc_id                  = aws_vpc.aps_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "aps_internet" {
  vpc_id = aws_vpc.aps_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aps_vpc.id

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.aps_vpc.id
  route_table_id = aws_route_table.public.id
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Add the route to the route table
resource "aws_route" "aps_public_internet" {
  route_table_id          = aws_route_table.public.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.aps_internet.id
}

# Creating KeyPair
resource "aws_key_pair" "deployer" {
  key_name   = "book-deployer-key"
  public_key = file(var.pub_key) # Adjust the path to your public key
}

# Security group to allow inbound SSH and all outbound traffic
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = aws_vpc.aps_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #can be changed to your VPN Outbound IP
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "book_server" {
  ami           = "ami-0e0e417dfa2028266"
  instance_type = "t3a.micro"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

 root_block_device {
    volume_size = 10  # Adjust the size as needed
    volume_type = "standard"  # Adjust the volume type as needed
    encrypted   = true   # Enable encryption
  }

  tags = {
    Name = "book-api-server"
  }

  depends_on = [
    aws_key_pair.deployer,
    aws_subnet.public,
    aws_security_group.allow_ssh
  ]
  # Optional: Ensure the instance is fully running before executing the provisioner
  provisioner "remote-exec" {
    inline = [
      "echo Instance is up and running."
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
      ansible-playbook -i "${self.public_ip}," book_deploy.yaml --user ec2-user -e "image_name=${var.image_name} tag=${var.image_tag}"
    EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"  # Optional: Disable host key checking for simplicity
    }

    # Ensure this runs only after the instance is created and accessible
    when = create
  }
}

output API_URL {
  value       = "API is running on http://${aws_instance.book_server.public_ip}:5000"
  description = "Public Ip of the server"
}
