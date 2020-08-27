# Segmented Environements

Example

```hcl
variable "prefix" {
  type    = string
  default = "test-environment"
}
locals {

  # creates cidr ranges for subnets
  vpc_cidr = "10.7.0.0/16"
  vpc_subnets = cidrsubnets(local.vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6)

  # creates cidr ranges for k8s clusters
  pod_cidr = "100.64.0.0/10"
  pod_subnets = cidrsubnets(local.pod_cidr, 6, 6, 6, 6, 6, 6, 6, 6)
  
}

data "aws_availability_zones" "available" {}
# Adjust the AZs in the VCP if using a region other than us-west-2

module "vpc_sofi" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.21.0"
  name    = "${var.prefix}-VPC"
  azs     = [
    data.aws_availability_zones.available.names[0], 
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
    data.aws_availability_zones.available.names[3],
    ]
  cidr    = local.vpc_cidr

  public_subnets  = [local.vpc_subnets[0], local.vpc_subnets[2], local.vpc_subnets[4], local.vpc_subnets[6]]
  private_subnets = [local.vpc_subnets[1], local.vpc_subnets[3], local.vpc_subnets[5], local.vpc_subnets[7]]

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_inbound_acl_rules = [ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "block", "rule_number": 100, "to_port": 0 } ]
  tags = merge(
    var.default_tags,
    {
      "kubernetes.io/cluster/${var.prefix}" = "shared"
    },
  )
}

module "apple_environment" {
  source = "./modules/terraform_segmented_environments"

  cluster_name           = "apple"
  pod_network_cidr_block = local.pod_subnets[0]
  subnet_id              = module.vpc_sofi.public_subnets[0]
  vpc_id                 = module.vpc_sofi.vpc_id
  tags                   = var.default_tags
  gateway_count          = 1
  db_postgres_count      = 0
  ssh_server_count       = 0
}
```
