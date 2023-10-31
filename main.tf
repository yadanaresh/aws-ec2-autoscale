provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr_block_a
  availability_zone = "${var.region}a"
  tags = {
    Name = "subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr_block_b
  availability_zone = "${var.region}b"
  tags = {
    Name = "subnet-b"
  }
}


# ... [Security groups, Load Balancers, Launch Templates, Auto Scaling Groups]


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  #vpc_id      = "aws_vpc.my_vpc.id"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  enable_deletion_protection = false

  enable_http2      = true

  security_groups = [aws_security_group.alb_sg.id]

  #enable_deletion_protection = false
}

resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.my_vpc.id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

data "aws_ami" "latest_rhel9" {
  most_recent = true
  #owners      = ["309956199498"]  # Red Hat's AWS account ID

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-launch-template-"
  ebs_optimized = false
  instance_type = "t2.micro"
  key_name = "terrafrom-aws"
  image_id      = "ami-05a5f6298acdb05b6"  # This line specifies the RHEL 9 AMI ID
  #security_group_names = ["aws_security_group.ec2_sg.id"]
block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 18
    }
  }

user_data = base64encode(templatefile("${path.module}/user_data_script.sh", {
    region = var.region
}))
 # Add this line to enable public IP for instances launched from this template
  network_interfaces {
    associate_public_ip_address = true
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name_prefix                 = "my-asg-"
  max_size                    = 3
  min_size                    = 1
  desired_capacity            = 2
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
  target_group_arns            = [aws_lb_target_group.my_target_group.arn]
  vpc_zone_identifier           = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  health_check_type            = "ELB"
  health_check_grace_period    = 300
  termination_policies         = ["Default"]
  force_delete                 = true
}
