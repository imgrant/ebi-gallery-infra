# EBI01948 Technical Challenge

Cloud infrastructure declaration and deployment code for a technical challenge set as part of assessment at the EMBL-EBI (EBI01948).

## ⚡️ Quick start

```shell
$ git clone https://github.com/imgrant/ebi-gallery-infra.git
$ cd ebi-gallery-infra/terraform
$ terraform init && terraform apply
$ cd ../ansible
$ ./deploy_ebi_gallery.sh
```

## ❓ Task brief

> An international photography community wants to create an open online platform for their gallery, where any user can upload an image to later be published publicly, and receive verification back that the image is of a supported size and resolution. You need to develop and deploy a small application which will allow a user to upload an image file, and then return the size and resolution of the image. 

## 📒 Solution overview

To develop the application, I started with an [existing example image gallery application](https://github.com/waleedahmad/LaravelGallery), described in a [blog article](https://quantizd.com/building-an-image-gallery-with-laravel-and-react/) as a tutorial of how to build a simple image upload application with Laravel and ReactJS.

> [Laravel](https://laravel.com/) is an open-source PHP framework for web applications; [React](https://reactjs.org/) is an open-source frontend JavaScript library for building web user interfaces.

### 🔧 Application development

The application required some additional features to meet the challenge requirements (verification of image size and resolution). It was also re-factored for better cloud-native functionality and containerised.

> Source code for the application is available at https://github.com/imgrant/LaravelGallery.

A continuous integration workflow (using GitHub Actions) is also deployed with the repository, which builds the container images and pushes them to a container registry repo at [Docker Hub](https://hub.docker.com/u/igrnt).

### 🏗️ Infrastructure & deployment

This repository contains code for deploying the service, using [Terraform](https://www.terraform.io/) to declare and provision the cloud infrastructure, and [Ansible](https://www.ansible.com/) for configuration management and application deployment.

## 🧰 Requirements

  - An [AWS account](https://aws.amazon.com/) with appropriately defined [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) or a [credentials configuration file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  - [git](https://git-scm.com/) (`>=2.8.0` recommended) [installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your computer
  - [terraform](https://www.terraform.io/) `>=1.1.0` [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started) on your computer
  - [ansible](https://docs.ansible.com/) `>=2.9.10` (`>=2.10` recommended) [installed](https://docs.ansible.com/ansible-core/devel/installation_guide/intro_installation.html) on your computer
  - [terraform-inventory](https://github.com/adammck/terraform-inventory) `v0.10` (latest recommended, a copy is included in this repo)

## 🚚 Usage

🔔 The following example shows sample values for sensitive or specific parameters.

1. ### Configure your AWS credentials using the AWS CLI:

    ```shell
    $ aws configure
    AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
    AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    Default region name [None]: eu-west-2
    Default output format [None]:
    ```

2. ### Clone the repository from GitHub:

    ```shell
    $ git clone https://github.com/imgrant/ebi-gallery-infra.git
    Cloning into 'ebi-gallery-infra'...
    remote: Enumerating objects: 5, done.
    remote: Counting objects: 100% (5/5), done.
    remote: Compressing objects: 100% (5/5), done.
    remote: Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
    Unpacking objects: 100% (5/5), 1.75 KiB | 448.00 KiB/s, done.
    ```

3. ### Prepare the Terraform environment:

    ```shell
    $ cd ebi-gallery-infra/terraform
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

4. ### Apply the Terraform plan to create the cloud infrastructure:

    ```shell
    terraform apply

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      # aws_ebs_volume.ebi-volume will be created
      + resource "aws_ebs_volume" "ebi-volume" {
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

      Enter a value: yes

    tls_private_key.ebi_gallery_key: Creating...
    tls_private_key.ebi_gallery_key: Creation complete after 3s [id=e7a32451f402fbc652e5f13a8a87dc66ad0d3f6c]
    local_file.private_key: Creating...
    <... another long output section proceeds as Terraform performs the creation operations ...>

    Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

    Outputs:

    ebs_volume_device = "/dev/xvde"
    ec2_arn = "arn:aws:ec2:eu-west-2:XXXXX:instance/i-0x0x0x0x0x0x0x0ef"
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

5. ### Install the required Ansible collections and roles:

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

    💡 The output you see may differ from that above, depending on what Ansible roles
    and collections you do or don't already have installed.

6. ### Run the Ansible playbook to configure the system and deploy the app:

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

   💡 `terraform-inventory` constructs the Ansible inventory dynamically from theTerraform state, passing in some key variables.
   The SSH key file created by the Terraform plan is used to authenticate, and host key checking is disabled in Ansible to bypass the unknown host key prompt.

7. ### 🥳 Go to the application URL and use the interface to browse and upload images

    ![Laravel Gallery login screen](laravel_gallery_login_page.png "Laravel Gallery login screen")

    💡 The app URL (i.e. the Elastic IP address) is displayed as the output from the final task in the Ansible playbook:

    ```
    TASK [EBI Gallery app URL] *****************************************************************************************
    ok: [203.0.113.79] => {
        "msg": "Browse to the application at http://203.0.113.79"
    }
    ```

8. ### 🍵 When you're done, tear down the infrastructure resources using Terraform:

    ```shell
    $ cd ../terraform
    $ terraform destroy
    <... a large mount of output scrolls as Terraform refreshes the known vs actual state of your infrastructure ...>
    aws_eip.ebi-gallery-ip: Refreshing state... [id=eipalloc-063ed3e3e84412707]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      - destroy

    Terraform will perform the following actions:

      # aws_ebs_volume.ebi-volume will be destroyed
      - resource "aws_ebs_volume" "ebi-volume" {
    <... a large amount of output is shown, indicating what Terraform will destroy ...>

    Plan: 0 to add, 0 to change, 38 to destroy.

    Changes to Outputs:
      - ebs_volume_device                      = "/dev/xvde" -> null
      - ec2_arn                                = "arn:aws:ec2:eu-west-2:***REMOVED***:instance/i-01bfad8fb63142cdf" -> null
      - ec2_capacity_reservation_specification = [
          - {
              - capacity_reservation_preference = "open"
              - capacity_reservation_target     = []
            },
        ] -> null
      - ec2_id                                 = "i-01bfad8fb63142cdf" -> null
      - ec2_instance_state                     = "running" -> null
      - ec2_primary_network_interface_id       = "eni-07b33bd58cb7865ea" -> null
      - ec2_tags_all                           = {
          - "Environment" = "dev"
          - "Name"        = "ebi-gallery-stack"
          - "Owner"       = "ebi-gallery-app"
        } -> null
      - elastic_ip                             = "3.11.28.43" -> null
      - private_key                            = "ebi_gallery_key.pem" -> null

    Do you really want to destroy all resources?
      Terraform will destroy all your managed infrastructure, as shown above.
      There is no undo. Only 'yes' will be accepted to confirm.

      Enter a value: yes
    
    local_file.private_key: Destroying... [id=f4194934c2a85425f59cf68f02c3e76a1413a528]
    <... a large amount of output is shown as Terraform performs the planned operations ...>
    module.vpc.aws_vpc.this[0]: Destruction complete after 1s

    Destroy complete! Resources: 38 destroyed.
    ```
