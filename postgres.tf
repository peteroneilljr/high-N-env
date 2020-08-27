resource "random_password" "db_postgres" {
  count  = var.db_postgres_count > 0 ? 1 : 0
  length           = 26
  special          = true
  override_special = "!#$%&*()-_=+:?"
}

module "sg_db_postgres" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.cluster_name
  description = "Security group for PostgreSQL publicly open"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["postgresql-tcp"]

  create = var.db_postgres_count > 0 ? true : false
}
data "aws_subnet_ids" "selected" {
  vpc_id = var.vpc_id
}
module "db_postgres" {
  source = "terraform-aws-modules/rds/aws"

  name       = var.cluster_name
  identifier = "${var.cluster_name}-postgres-10"

  # NOTE: Do NOT use 'user' as the value for 'username'
  username = var.cluster_name
  password = var.db_postgres_count > 0 ? random_password.db_postgres[0].result : null

  engine                  = "postgres"
  engine_version          = "10"
  major_engine_version    = "10"
  family                  = "postgres10"
  instance_class          = "db.t2.medium"
  allocated_storage       = 5
  storage_encrypted       = false
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  deletion_protection     = false

  # networking info
  port                   = "5432"
  vpc_security_group_ids = [module.sg_db_postgres.this_security_group_id]
  subnet_ids             = data.aws_subnet_ids.selected.ids

  create_db_instance        = var.db_postgres_count > 0 ? true : false
  create_db_parameter_group = var.db_postgres_count > 0 ? true : false
  create_db_subnet_group    = var.db_postgres_count > 0 ? true : false
  create_db_option_group    = var.db_postgres_count > 0 ? true : false

  tags = var.tags
}

resource "sdm_resource" "db_postgres" {
  count = var.db_postgres_count
  postgres {
    name = "${var.cluster_name}-postgres-${count.index}"
    hostname = module.db_postgres.this_db_instance_address
    username = module.db_postgres.this_db_instance_username
    password = random_password.db_postgres[0].result
    database = module.db_postgres.this_db_instance_name
    port     = 5432

    tags = var.tags
  }
}