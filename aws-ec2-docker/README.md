# 🐳 AWS EC2 deployment

## 👀 Overview

This deployment uses [_Terraform_](https://www.terraform.io/) to provision the basic cloud infrastructure in [Amazon Web Services](https://aws.amazon.com/) (a virtual machine, block storage, associated virtual networking, internet gateway, public IP address, and an SSH key pair).

[_Ansible_](https://www.ansible.com/) is used to configure the system and deploy the application. Some glue is provided in the form a dynamic inventory plugin for Ansible, [_terraform-inventory_](https://github.com/adammck/terraform-inventory), which is used to help pass output from Terraform to Ansible.

You can deploy the application yourself using this code; see [⚡️ Quick start](#-quick-start) or the workflow in [🚚 Usage](#-usage), below.

### Features

  - Single EC2 compute instance in AWS (in a public subnet with a dedicated VPC)
  - EBS volume attached for persistent storage (application database and photo uploads)
  - Tags are set on AWS resources to enable easy grouping, e.g. for cost analysis
  - Docker Compose multi-container architecture:
    - MySQL database container
    - PHP-FPM application backend container
    - NGINX container serving application frontend and proxying backend requests
    - Named volume shared with the frontend and backend for storing and serving images uploaded via the application
  - Application served over plain HTTP via an Elastic IP attached to the EC2 instance

## ⚡️ Quick start

```shell
$ git clone https://github.com/imgrant/ebi-gallery-infra.git
$ cd ebi-gallery-infra/aws-ec2-docker/terraform
$ terraform init && terraform apply
$ cd ../ansible
$ ./deploy_ebi_gallery.sh
```

## 🚚 Usage

### 🧰 Requirements

  - An [AWS account](https://aws.amazon.com/) with appropriately defined [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) or a [credentials configuration file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  - [git](https://git-scm.com/) (`>=2.8.0` recommended) [installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your computer
  - [terraform](https://www.terraform.io/) `>=1.1.0` [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started) on your computer
  - [ansible](https://docs.ansible.com/) `>=2.9.10` (`>=2.10` recommended) [installed](https://docs.ansible.com/ansible-core/devel/installation_guide/intro_installation.html) on your computer
  - [terraform-inventory](https://github.com/adammck/terraform-inventory) `v0.10` (latest recommended, a copy is included in this repo)

### 🚀 Workflow

🔔 The following example shows sample values for sensitive or specific parameters; substitute your own configuration accordingly.

1. #### Configure your AWS credentials

    e.g. Using the AWS CLI:

    ```shell
    $ aws configure
    AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
    AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    Default region name [None]: eu-west-2
    Default output format [None]:
    ```

2. #### Clone the repository from GitHub

    ```shell
    $ git clone https://github.com/imgrant/ebi-gallery-infra.git
    Cloning into 'ebi-gallery-infra'...
    remote: Enumerating objects: 5, done.
    remote: Counting objects: 100% (5/5), done.
    remote: Compressing objects: 100% (5/5), done.
    remote: Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
    Unpacking objects: 100% (5/5), 1.75 KiB | 448.00 KiB/s, done.
    ```

3. #### Prepare the Terraform environment

    ```shell
    $ cd ebi-gallery-infra/aws-ec2-docker/terraform
    $ terraform init
    Initializing modules...
    Downloading registry.terraform.io/terraform-aws-modules/ec2-instance/aws 3.4.0 for ec2...
    - ec2 in .terraform/modules/ec2
    Downloading registry.terraform.io/terraform-aws-modules/security-group/aws 4.8.0 for security_group...
    - security_group in .terraform/modules/security_group
    Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 3.11.5 for vpc...
    - vpc in .terraform/modules/vpc

    Initializing the backend...

    Initializing provider plugins...
    - Finding hashicorp/tls versions matching "~> 3.1.0"...
    - Finding hashicorp/local versions matching "~> 2.1.0"...
    - Finding hashicorp/aws versions matching ">= 3.0.0, ~> 3.27, >= 3.63.0, >= 3.72.0"...
    - Installing hashicorp/tls v3.1.0...
    - Installed hashicorp/tls v3.1.0 (signed by HashiCorp)
    - Installing hashicorp/local v2.1.0...
    - Installed hashicorp/local v2.1.0 (signed by HashiCorp)
    - Installing hashicorp/aws v3.74.0...
    - Installed hashicorp/aws v3.74.0 (signed by HashiCorp)

    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!
    
    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

4. #### Apply the Terraform plan to create the cloud infrastructure

    You can use `terraform plan` to preview what Terraform would do before actually applying the plan. When satisfied, use `terraform apply` to kick off the infrastructue provisioning:

    ```shell
    $ terraform apply

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

    <... a lot of long output is shown, illustrating what Terraform will do ...>

    Plan: 38 to add, 0 to change, 0 to destroy.

    Changes to Outputs:
      + ebs_volume_device                      = "/dev/xvde"
      + ec2_arn                                = (known after apply)
      + ec2_capacity_reservation_specification = (known after apply)
      + ec2_id                                 = (known after apply)
      + ec2_instance_state                     = (known after apply)
      + ec2_primary_network_interface_id       = (known after apply)
      + ec2_tags_all                           = {
          + "Environment" = "dev"
          + "Name"        = "ebi-gallery-stack"
          + "Owner"       = "ebi-gallery-app"
          }
      + elastic_ip                             = (known after apply)
      + private_key                            = "ebi_gallery_key.pem"

    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: 
    ```

    Type `yes` to proceed with applying the Terraform plan. The outputs will be displayed when run is complete:

    ```
    tls_private_key.ebi_gallery_key: Creating...
    tls_private_key.ebi_gallery_key: Creation complete after 3s [id=e7a32451f402fbc652e5f13a8a87dc66ad0d3f6c]
    local_file.private_key: Creating...

    <... another long output section proceeds as Terraform performs the creation operations ...>

    Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

    Outputs:

    ebs_volume_device = "/dev/xvde"
    ec2_arn = "arn:aws:ec2:eu-west-2:***REMOVED***:instance/i-0x0x0x0x0x0x0x0ef"
    ec2_capacity_reservation_specification = tolist([
      {
        "capacity_reservation_preference" = "open"
        "capacity_reservation_target" = tolist([])
      },
    ])
    ec2_id = "i-0x0x0x0x0x0x0x0ef"
    ec2_instance_state = "running"
    ec2_primary_network_interface_id = "eni-0x0x0x0x0x0x0x0ef"
    ec2_tags_all = tomap({
      "Environment" = "dev"
      "Name" = "ebi-gallery-stack"
      "Owner" = "ebi-gallery-app"
    })
    elastic_ip = "203.0.113.79"
    private_key = "ebi_gallery_key.pem"
    ```

    ⚠️ Note that in this example code, no [backend](https://www.terraform.io/language/settings/backends) is defined; the Terraform [state](https://www.terraform.io/language/state) will be stored locally in a file named `terraform.tfstate`. Keep this safe, as you will need it to properly destroy your infrastructure later.[^1]
    
[^1]: If you lose or delete the `terraform.tfstate` state file, Terraform won't be able to destroy the infrastructure it previously created. Manually reconstructing the state file is possible, but painstaking and laborious. [_aws-nuke_](https://github.com/rebuy-de/aws-nuke) is useful tool that can be used to comprehensively destroy resources in an AWS account. An example config file for _aws-nuke_ is provided in [terraform/aws-nuke-config.yml.sample](terraform/aws-nuke-config.yml.sample) — see the [_aws-nuke_ documentation](https://github.com/rebuy-de/aws-nuke#usage) for how to use it.

5. #### Install the required Ansible collections and roles

    ```shell
    $ cd ../ansible
    $ ansible-galaxy collection install -r requirements.yml
    Starting galaxy collection install process
    Process install dependency map
    Starting collection install process
    Skipping 'community.general' as it is already installed
    Skipping 'community.docker' as it is already installed

    $ ansible-galaxy role install -r requirements.yml
    Starting galaxy role install process
    [WARNING]: - mrlesmithjr.manage-lvm (v0.2.5) is already installed - use --force to change version to unspecified
    [WARNING]: - geerlingguy.pip (2.1.0) is already installed - use --force to change version to unspecified
    [WARNING]: - geerlingguy.docker (4.1.3) is already installed - use --force to change version to unspecified
    ```

    The output you see may differ from that above, depending on what Ansible roles and collections you do or don't already have installed.

    💡 With Ansible `>=2.10`, roles and collections can be installed from a requirements file together in a single step with, e.g.: `ansible-galaxy install -r requirements.yml`

6. #### Run the Ansible playbook to configure the system and deploy the app

    ```shell
    $ TF_STATE=../terraform/  ANSIBLE_HOST_KEY_CHECKING=False \
    ansible-playbook -i ./terraform-inventory \
      -u ubuntu --key-file=../terraform/ebi_gallery_key.pem \
      ebi-gallery.yaml

    PLAY [EBI Gallery host configuration] ******************************************************************************

    TASK [Gathering Facts] *********************************************************************************************
    ok: [203.0.113.79]

    <... a large amount of output is shown as Ansible executes the tasks in the playbook ...>
    
    PLAY RECAP *********************************************************************************************************
    203.0.113.79                 : ok=47   changed=25   unreachable=0    failed=0    skipped=18   rescued=0    ignored=0   
    ```

   `terraform-inventory` constructs the Ansible inventory dynamically from the Terraform state, passing in some key variables. The `TF_STATE` environment variable tells `terraform-inventory` where to look for the Terraform state file (from which it extracts the Terraform outputs).

   The SSH key file created by the Terraform plan is used to authenticate, host key checking is disabled in Ansible (with the `ANSIBLE_HOST_KEY_CHECKING=False` environment variable) to bypass the unknown host key prompt.

   💡 You can use the SSH private key file that Terraform writes out to log into the EC2 instance directly, using the Elastic IP address (shown in the Ansible output above):

   ```shell
   ssh -i ../terraform/ebi_gallery_key.pem ubuntu@203.0.113.79
   ```

   💡 The [`docker-compose.yml`](https://github.com/imgrant/LaravelGallery/blob/master/docker-compose.yml) file provided with the application builds the images for the backend and frontend services from the source code. This can take a long time in the first instance, especially on small EC2 types such as the default [t2.micro](https://aws.amazon.com/ec2/instance-types/t2/). To alleviate this, you could either assign a larger size via the `ec2_instance_size` [Terraform input variable](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables), or manually reconfigure the `docker-compose.yml` container definitions to pull the [pre-existing images from CI builds](https://hub.docker.com/u/igrnt).

7. #### 🥳 Go to the application URL and use the interface to browse and upload images

    The app URL (i.e. the Elastic IP address) is displayed as the output from the final task in the Ansible playbook:

    ```
    TASK [EBI Gallery app URL] *****************************************************************************************
    ok: [203.0.113.79] => {
        "msg": "Browse to the application at http://203.0.113.79"
    }
    ```

    ![Laravel Gallery login screen](laravel_gallery_login_page.png "Laravel Gallery login screen")

    See the [application source code repository](https://github.com/imgrant/LaravelGallery) for more information on the app itself and how to use it.

    💡 The application uses [Laravel's built-in authentication controllers](https://laravel.com/docs/5.6/authentication), you can use the 'Register' function to create a user account (need not be a real email address) in order to access the app.[^2]

[^2]: Since this is a demo application, email functionality is not configured or enabled via the deployment. The password reset feature does not function.

8. #### 🍵 When you're done, tear down the infrastructure resources using Terraform

    ```shell
    $ cd ../terraform
    $ terraform destroy

    <... a large mount of output scrolls as Terraform refreshes the known vs actual state of your infrastructure ...>

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      - destroy

    Terraform will perform the following actions:

    <... a large amount of output is shown, indicating what Terraform will destroy ...>

    Plan: 0 to add, 0 to change, 38 to destroy.

    Changes to Outputs:
      - ebs_volume_device                      = "/dev/xvde" -> null
      - ec2_arn                                = "arn:aws:ec2:eu-west-2:***REMOVED***:instance/i-0x0x0x0x0x0x0x0ef" -> null
      - ec2_capacity_reservation_specification = [
          - {
              - capacity_reservation_preference = "open"
              - capacity_reservation_target     = []
            },
        ] -> null
      - ec2_id                                 = "i-0x0x0x0x0x0x0x0ef" -> null
      - ec2_instance_state                     = "running" -> null
      - ec2_primary_network_interface_id       = "eni-0x0x0x0x0x0x0x0ef" -> null
      - ec2_tags_all                           = {
          - "Environment" = "dev"
          - "Name"        = "ebi-gallery-stack"
          - "Owner"       = "ebi-gallery-app"
        } -> null
      - elastic_ip                             = "203.0.113.79" -> null
      - private_key                            = "ebi_gallery_key.pem" -> null

    Do you really want to destroy all resources?
      Terraform will destroy all your managed infrastructure, as shown above.
      There is no undo. Only 'yes' will be accepted to confirm.

      Enter a value: yes
    
    <... a large amount of output is shown as Terraform performs the planned operations ...>

    Destroy complete! Resources: 38 destroyed.
    ```
