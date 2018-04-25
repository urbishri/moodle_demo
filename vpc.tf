# Create a VPC to launch our instances into
resource "aws_vpc" "vpc_cidr" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TestVPC"
  }
}

# Create a way out to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_cidr.id}"
  tags {
        Name = "InternetGateway"
    }
}

# Public route as way out to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_cidr.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}


# Create the custom route table
resource "aws_route_table" "custom_route_table" {
    vpc_id = "${aws_vpc.vpc_cidr.id}"

    tags {
        Name = "Custom route table"
    }
}

# Create custom route
resource "aws_route" "custom_route" {
                route_table_id  = "${aws_route_table.custom_route_table.id}"
                destination_cidr_block = "0.0.0.0/0"
                nat_gateway_id = "${aws_nat_gateway.nat.id}"
}



# Create a subnet in the AZ us-east-2a
resource "aws_subnet" "subnet_us_east_2a" {
  vpc_id                  = "${aws_vpc.vpc_cidr.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"
  tags = {
                Name =  "Public Subnet"
  }
}

# Create a subnet in the AZ us-east-2b
resource "aws_subnet" "subnet_us_east_2b" {
  vpc_id                  = "${aws_vpc.vpc_cidr.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
                Name =  "Private Subnet"
  }
}

# Create an EIP for the natgateway
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.igw"]
}


# Create a nat gateway and it will depend on the internet gateway creation
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.subnet_us_east_2a.id}"
    depends_on = ["aws_internet_gateway.igw"]
}

# Associate subnet subnet_us_east_2a to public route table
resource "aws_route_table_association" "subnet_us_east_2a_association" {
    subnet_id = "${aws_subnet.subnet_us_east_2a.id}"
    route_table_id = "${aws_vpc.vpc_cidr.main_route_table_id}"
}

# Associate subnet subnet_us_east_2b to private route table
resource "aws_route_table_association" "subnet_us_east_2b_association" {
    subnet_id = "${aws_subnet.subnet_us_east_2b.id}"
    route_table_id = "${aws_route_table.custom_route_table.id}"
}
resource "aws_security_group" "Public_Security_Group" {
    name = "public_sg"
    description = "Allow incoming connections."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_cidr.id}"

    tags {
        Name = "Public_SG"
    }
}

resource "aws_security_group" "Private_Security_Group" {
    name = "private_sg"
    description = "Allow private connections."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.Public_Security_Group.id}"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${aws_security_group.Public_Security_Group.id}"]
	}
     ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${aws_security_group.Public_Security_Group.id}"]
        }
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
     egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc_cidr.id}"

    tags {
        Name = "Private_SG"
    }
}
