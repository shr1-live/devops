variable "names" {
  type = list(string)
}

resource "terraform_data" "msg" {
  for_each = toset(var.names)
  input    = "hi ${each.key}"
}

output "messages" {
  value = [for m in terraform_data.msg : m.input]
}
