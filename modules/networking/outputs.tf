output "fp-vpc-id" {
  value = aws_vpc.fp-vpc.id
}

output "fp-pub-subs-ids" {
  value = aws_subnet.fp-pub-sunbets[*].id
}