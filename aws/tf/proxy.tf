### Proxy Configuration and internet access for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_prefix}igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.aws_default_zones[0].zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}public_subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env_prefix}public_rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_access" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}security_group"
  }
}

#### SSH Key Generation
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "./.ssh/terraform_aws_rsa"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "./.ssh/terraform_aws_rsa.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu_proxy_ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

## Proxy Configuration
resource "aws_instance" "proxy" {
  ami                         = var.aws_default_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_access.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  depends_on = [
    aws_security_group.allow_access,
    aws_internet_gateway.igw
  ]

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install -y nginx

            load_module /usr/lib/nginx/modules/ngx_stream_module.so;

            # Update the NGINX configuration file (/etc/nginx/nginx.conf) to use SNI from incoming TLS sessions for routing traffic to the appropriate servers on ports 443 and 9092.
            cat << 'EOF' | sudo tee /etc/nginx/nginx.conf
            events {}
            stream {
                map $ssl_preread_server_name $targetBackend {
                    default $ssl_preread_server_name;
                }

                # On lookup failure, reconfigure to use the cloud provider's resolver
                # resolver 169.254.169.253; # for AWS
                # resolver 168.63.129.16;  # for Azure
                # resolver 169.254.169.254;  # for Google

                server {
                    listen 9092;

                    proxy_connect_timeout 1s;
                    proxy_timeout 7200s;

                    resolver 169.254.169.253;

                    proxy_pass $targetBackend:9092;
                    ssl_preread on;
                }


                server {
                    listen 443;

                    proxy_connect_timeout 1s;
                    proxy_timeout 7200s;

                    resolver 169.254.169.253;

                    proxy_pass $targetBackend:443;
                    ssl_preread on;
                }

                log_format stream_routing '[$time_local] remote address $remote_addr '
                                                                    'with SNI name "$ssl_preread_server_name" '
                                                                    'proxied to "$upstream_addr" '
                                                                    '$protocol $status $bytes_sent $bytes_received '
                                                                    '$session_time';
                access_log /var/log/nginx/stream-access.log stream_routing;
            }
            'EOF'
            
            # Restart NGINX to apply the changes
            sudo systemctl restart nginx
            EOF
  tags = {
    Name = "${var.env_prefix}ubuntu_nginx_proxy"
  }
}


