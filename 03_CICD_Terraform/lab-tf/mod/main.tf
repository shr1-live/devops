module "greeter" {
  source = "./modules/greeter"
  names  = ["asha", "ravi", "meera"]
}

output "all" {
  value = module.greeter.messages
}
