resource "aws_instance" "Bastion_Host" {
   ami  = "ami-25615740"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.Public_Security_Group.id}"]
   subnet_id = "${aws_subnet.subnet_us_east_2a.id}"
   key_name = "${var.key_name}"
   source_dest_check = false

  tags {
    Name = "Bastion Host"
  }
}
resource "aws_instance" "Moodle_Server" {
   depends_on = ["aws_nat_gateway.nat"]
   ami  = "ami-25615740"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.Private_Security_Group.id}"]
   subnet_id = "${aws_subnet.subnet_us_east_2b.id}"
   key_name = "${var.key_name}"
   user_data = "${file("userdata.sh")}"
   source_dest_check = false

  tags {
    Name = "Moodle Server"
  }
}

resource "aws_elb" "test_elb" {
	  name = "Test-elb"
	
	  # The same availability zone as our instance
	  subnets = ["${aws_subnet.subnet_us_east_2a.id}","${aws_subnet.subnet_us_east_2b.id}"]
	
	  security_groups = ["${aws_security_group.Public_Security_Group.id}"]
	
	  listener {
	    instance_port     = 80
	    instance_protocol = "http"
	    lb_port           = 80
	    lb_protocol       = "http"
            #ssl_certificate_id = "arn:aws:iam::027515724398:server-certificate/MyCertificate"
	  }
	
	  health_check {
	    healthy_threshold   = 2
	    unhealthy_threshold = 2
	    timeout             = 3
	    target              = "TCP:80"
	    interval            = 30
	  }
	
	  # The instance is registered automatically
	
	  instances                   = ["${aws_instance.Moodle_Server.id}"]
	  cross_zone_load_balancing   = true
	  idle_timeout                = 400
	  connection_draining         = true
	  connection_draining_timeout = 400
	 }
