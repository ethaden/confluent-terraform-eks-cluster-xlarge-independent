# Run the script to get the environment variables of interest.
# This is a data source, so it will run at plan time.
data "external" "env" {
  program = ["${path.module}/locals-from-env.sh"]

  # For Windows (or Powershell core on MacOS and Linux),
  # run a Powershell script instead
  #program = ["${path.module}/env.ps1"]
}

#output "env" {
#    value = data.external.env.result
#}

locals {
    confluent_tags = {
        owner = var.owner!="" ? var.owner : data.external.env.result["user"]
        owner_fullname = var.owner_fullname!="" ? var.owner_fullname : data.external.env.result["owner_fullname"]
        owner_email = var.owner_email!="" ? var.owner_email : data.external.env.result["owner_email"]
        tf_last_updated = var.tf_last_updated!="" ? var.tf_last_updated : data.external.env.result["current_datetime"]
        divvy_last_modified_by = var.owner_email!="" ? var.owner_email : data.external.env.result["owner_email"]
    }
    # Comment the next four lines if this project is not using Confluent Cloud
    # confluent_creds = {
    #     api_key = data.external.env.result["api_key"]
    #     api_secret = data.external.env.result["api_secret"]
    # }

    public_ssh_key = var.public_ssh_key!="" ? var.public_ssh_key : data.external.env.result["public_ssh_key"]
    username = var.username!="" ? var.username : data.external.env.result["user"]
    resource_prefix = var.resource_prefix!="" ? var.resource_prefix : local.username
    private_hostedzone_vpc = var.private_hostedzone_vpc!="" ? var.private_hostedzone_vpc : "${local.resource_prefix}.internal"
    vpn_client_names = length(var.vpn_client_names)!=0 ? var.vpn_client_names: [local.username]
    vpn_client_names_to_domain = { for client_name in local.vpn_client_names: client_name => "${client_name}.${var.vpn_base_domain}" }
}

output "confluent_tags" {
    value = local.confluent_tags
}
