# Terraform - Avi Demo Environment
** NOTE: This is meant to be used with [Ansible Demo Spinner](https://github.com/alexfeig/avi-ansible-demo-spinner). If you don't wish to use it, please remove `azure_post_provision.tf` prior to running.

This Terraform environment will spin up:

* All required network security groups, vnets, and other required objects
* An Avi Controller in the version specified
* A user specified number of webservers running Ubuntu and Apache, with an index page indicating which server it is

Once done, it will make a call to Ansible for post provisioning configuration.

## Requirements

* Azure CLI - for OS X, [Homebrew is easiest](https://brew.sh/) is easiest
* SSH key placed in `/keys` that **matches** the value of your project name
* `terraform.tfvars` edited to your liking

## Sample TF Variables
Create a `terraform.tfvars` file with the following:

```avi_username = "alex"
controller_version = "17.2.14"
admin_password = "password"
admin_username = "alex"
project_name = "alex-tf"
ansible_playbook_path = "../ansible/demo_spinner/main.yml"
resource_group = "resource-group"
subscription_id = "1234"
tenant_id = "1234"
```