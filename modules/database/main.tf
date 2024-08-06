resource "aws_kms_key" "rds_kms" {
  description = "RDS KMS Key"
}

resource "aws_db_subnet_group" "rds_private_subnet_group" {
  name       = "${var.cluster_name}-rds-private-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "RDSPrivateSubnetGroup"
  }
}

resource "aws_db_subnet_group" "rds_public_subnet_group" {
  name       = "${var.cluster_name}-rds-public-subnet-group"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "RDSPublicSubnetGroup"
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage             = var.allocated_storage
  max_allocated_storage         = var.max_allocated_storage
  storage_type                  = var.storage_type
  engine                        = var.engine
  engine_version                = var.engine_version
  instance_class                = var.instance_class
  db_name                       = var.db_name
  username                      = var.username
  identifier                    = "db-${var.cluster_name}"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds_kms.key_id
  parameter_group_name          = "default.postgres16"
  db_subnet_group_name          = var.rds_public_access ? aws_db_subnet_group.rds_public_subnet_group.name : aws_db_subnet_group.rds_private_subnet_group.name
  vpc_security_group_ids        = var.rds_public_access ? [aws_security_group.public_rds_sg.id] : [aws_security_group.private_rds_sg.id]
  publicly_accessible           = var.rds_public_access

  multi_az = true

  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "RDSInstance"
  }
}

resource "null_resource" "create_user" {
  for_each = { for user in var.db_users : user.username => user }

  provisioner "local-exec" {
    command = <<-EOF
      export PGPASSWORD='${var.db_password}'; 
      psql -h ${aws_db_instance.rds_instance.address} -U docplanner -d postgres -c "
      DO \$\$ 
      BEGIN 
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${each.value.username}') THEN 
          CREATE USER ${each.value.username} WITH PASSWORD '${each.value.password}'; 
          GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${each.value.username}; 
        END IF; 
      END 
      \$\$;"
    EOF
  }

  depends_on = [aws_db_instance.rds_instance]
}

resource "aws_security_group" "private_rds_sg" {
  name        = "${var.cluster_name}-private-rds-sg"
  description = "Security group for private RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      ingress,
    ]
  }

  tags = var.tags

}

resource "aws_security_group" "public_rds_sg" {
  name        = "${var.cluster_name}-public-rds-sg"
  description = "Security group for public RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}