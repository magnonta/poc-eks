# Module to create and manage an RDS database instance for the "poc_db" (Proof of Concept Database).
# The module's source is located in the "../../modules/database" directory, which is expected to contain the necessary Terraform code for setting up the database.
module "poc_db" {
  source             = "../../modules/database"
  rds_public_access  = true
  cluster_name       = local.env.database.name
  private_subnet_ids = local.private_subnet_ids
  public_subnet_ids  = local.public_subnet_ids
  vpc_id             = aws_vpc.vpc.id

  storage_type          = local.env.database.storage_type
  engine                = local.env.database.engine
  engine_version        = local.env.database.engine_version
  instance_class        = local.env.database.instance_class
  db_name               = local.env.database.db_name
  username              = local.env.database.username
  allocated_storage     = local.env.database.allocated_storage
  max_allocated_storage = local.env.database.max_allocated_storage
  db_password           = var.db_password
  db_user               = var.db_user
  db_database           = var.db_database


  tags = {
    name = "poc-docplanner"
  }
}