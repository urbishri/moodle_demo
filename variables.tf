variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.2.0/24"
}

variable "ami" {
  description = "AMI for EC2"
  default = "ami-25615740"
}

variable "access_key" {
  description = "Access Key"
  default = "AKIAIOHXMW3CQA6PIIOQ"
}

variable "secret_key" {
  description = "Secret Access Key"
  default = "UeOu+53oL9mkOuW4O4gxPeamXV0yoloiX+UfqZbp"
}

variable "bucket_name" {
  description = "S3 Bucket Name"
  default = "moodledb2018"
}

variable "key_name" { 
  description = "Key Pair Name"
  default = "Moodle_Linux" 
}

