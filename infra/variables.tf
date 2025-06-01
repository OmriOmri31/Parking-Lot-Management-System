variable "aws_region"     { type = string }
variable "key_pair_name"  { type = string }

variable "db_name"        { type = string }
variable "db_user"        { type = string }
variable "db_password"    { type = string }   # sensitive

variable "my_ip" {       # lock down SSH
  type    = string
  default = "0.0.0.0/0"  # replace with x.x.x.x/32 after testing
}
