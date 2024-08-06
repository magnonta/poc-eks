variable "rds_public_access" {
  description = "Enable publicly accessible for database"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name for EKS Cluster"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the resources will be created"
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) to allocate for the DB instance"
  type        = number
}

variable "max_allocated_storage" {
  description = "The upper limit for RDS storage auto-scaling (in gigabytes)"
  type        = number
}

variable "storage_type" {
  description = "The storage type to be associated with the RDS instance (e.g., standard, gp2, io1)"
  type        = string
}

variable "engine" {
  description = "The name of the database engine to be used for the RDS instance (e.g., mysql, postgres)"
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine to use"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database to create when the RDS instance is launched"
  type        = string
}

variable "username" {
  description = "The username for the master DB user"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "db_users" {
  description = "List of users to be created in the database"
  type = list(object({
    username = string
    password = string
  }))
  default = [
    {
      username = "user1",
      password = "password1"
    },
    {
      username = "user2",
      password = "password2"
    },
    {
      username = "user3",
      password = "password3"
    }
  ]
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username for the database"
  type        = string
}

variable "db_database" {
  description = "Name of the database to be created"
  type        = string
}
