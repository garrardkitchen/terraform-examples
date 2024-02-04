variable "subscription_id" {
  description = "The ID of the subscription"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "workstream" {
  type    = string
  default = "compare-sample"
}

variable "tags" {
  description = "The tags to be applied to the resources"
  type        = map(string)
}

variable "resource_groups" {
  type = map(object({
    cidr = string
    snets = map(object({
      prefix = string
    }))
  }))
}