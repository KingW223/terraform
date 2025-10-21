provider "aws" {
    region = "us-west-2"  
}

resource "aws_instance" "foo" {
  ami           = "ami-0e1d35993cb249cee" # us-west-2
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance"
  }
}
