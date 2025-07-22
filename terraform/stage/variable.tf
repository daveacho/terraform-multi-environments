variable "projectName" {}
variable "environment" {}
variable "source_token" {
  sensitive = true
}
variable "influxdb_url" {}
variable "organisation" {}
variable "destination_org" {}
variable "destination_token" {}
variable "destination_influxdb_url" {}
variable "region" {}