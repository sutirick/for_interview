variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID to create the security group in"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids = list(string)
    self            = bool
    description     = string
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids = list(string)
    self            = bool
    description     = string
  }))
  default = [
    {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      self            = false
      description     = "Allow all outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Additional tags to apply to the security group"
  type        = map(string)
  default     = {}
}
