variable "pod_network_cidr_block" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
variable "subnet_id" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
variable "vpc_id" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
variable "num_workers" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}
variable "worker_instance_type" {
  type = string
  description = "(optional) describe your variable"
  default = "t3.medium"
}
variable "master_instance_type" {
  type = string
  description = "(optional) describe your variable"
  default = "t3.medium"
}
variable "enable_schedule_pods_on_master" {
  type = bool
  description = "(optional) describe your variable"
  default = true
}
variable "enable_calico_cni" {
  type = bool
  description = "(optional) describe your variable"
  default = true
}
variable "tags" {
  type = map(string)
  description = "(optional) describe your variable"
  default = {}
}
variable "sdm_port" {
  type = number
  description = "(optional) describe your variable"
  default = 5000
}
variable "gateway_count" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}
variable "db_postgres_count" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}
variable "ssh_server_count" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}
variable "cluster_name" {
  type = string
  description = "(optional) describe your variable"
  default = null
}
variable "sdm_ca_pub_key" {
  type = string
  description = "(optional) describe your variable"
  default = null
}



