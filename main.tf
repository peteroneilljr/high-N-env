
module "this_cluster" {
  source  = "github.com/peteroneilljr/terraform-aws-kubeadm"

  cluster_name = var.cluster_name
  pod_network_cidr_block = var.pod_network_cidr_block
  subnet_id = var.subnet_id
  vpc_id = var.vpc_id
  kubeconfig_dir = "~/.kube"
  num_workers = var.num_workers
  worker_instance_type = var.worker_instance_type
  master_instance_type = var.master_instance_type
  enable_schedule_pods_on_master = var.enable_schedule_pods_on_master
  enable_calico_cni = var.enable_calico_cni

  tags = var.tags
}

provider "kubernetes" {
  alias = "kubeadm"

  load_config_file       = true
  config_path = module.this_cluster.kubeconfig

}

module "strongdm_gateways" {
  source = "github.com/peteroneilljr/terraform_kubernetes_strongdm_gateways"
  
  sdm_app_name = module.this_cluster.cluster_name
  sdm_gateway_name = "${module.this_cluster.cluster_name}-gateway"
  gateway_count = var.gateway_count
  namespace = module.this_cluster.cluster_name
  expose_on_node_port = true

  dev_mode = true

  providers = {
    kubernetes = kubernetes.kubeadm
  }
  depends_on = [
    module.this_cluster.cluster_master_ip,
  ]
}
