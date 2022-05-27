provider "aws"{
    region ="us-east-2"
}
resource "aws_instance" "server" {
    ami=""
    instance_type ="t2.micro"
    subnet_id=""
    security_groups=""
    key_name=aws_key_pair.key.id

    tags={
        Name="terraform server"
    }
}

resource "aws_key_pair" "key" {
    key_name ="sample"
    public_key=
}