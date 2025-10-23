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
resource "aws_s3_bucket" "my_bucket" {
  bucket = "tf-bucket-example-12345"
  acl    = "private"

  tags = {
    Name        = "TF-Bucket"
    Environment = "Dev"
  }
}
