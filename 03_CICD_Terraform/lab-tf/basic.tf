variable "name" {
  default = "DevOps"
}

resource "terraform_data" "hello" {
  input = "Hello, ${var.name}"
}

output "greeting" {
  value = terraform_data.hello.input
}
