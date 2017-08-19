# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "ap-southeast-2"
}

data "aws_security_group" "sec_group" {
  id = "${var.security_group_id}"
}

output "vpc_id" { value = "${data.aws_security_group.sec_group.vpc_id}" }

resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

data "aws_ami" "ubuntu" {
  most_recent     = true
  #executable_users = ["self"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
    # https://cloud-images.ubuntu.com/locator/ec2/ - use aws ec2 describe-images --owners 575264825971
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  #name_regex = "^myami-\\d{3}"
  owners     = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.image_id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = [ "${data.aws_security_group.sec_group.name}" ]

  tags {
    name = "crash-course"
  }
}
