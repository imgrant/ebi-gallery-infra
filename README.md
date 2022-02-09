# EBI01948 Technical Challenge

Cloud infrastructure declaration and deployment code for a technical challenge set as part of assessment at the EMBL-EBI (EBI01948 — Hybrid Cloud DevOps Engineer).

## ❓ Task brief

The challenge was defined by the following instruction, with a timeframe of one week to complete (in the form of submitting the code repository URL):

  > An international photography community wants to create an open online platform for their gallery, where any user can upload an image to later be published publicly, and receive verification back that the image is of a supported size and resolution. You need to develop and deploy a small application which will allow a user to upload an image file, and then return the size and resolution of the image. 

## 📒 Solution overview

To develop the application, I started with an [existing example image gallery application](https://github.com/waleedahmad/LaravelGallery).

  > 💡 Source code for the application is available at https://github.com/imgrant/LaravelGallery.

For deployment, two example workflows are included in this repository (see [Infrastructure & deployment](#%EF%B8%8F-infrastructure--deployment) below).

### 🔧 Application development

The existing application is described in a [blog article](https://quantizd.com/building-an-image-gallery-with-laravel-and-react/) as a tutorial of how to build a simple image upload application with [Laravel](https://laravel.com/) and [ReactJS](https://reactjs.org/).

  > [Laravel](https://laravel.com/) is an open-source PHP framework for web applications; [React](https://reactjs.org/) is an open-source frontend JavaScript library for building web user interfaces.

The application required some additional features to meet the challenge requirements (e.g. verification of image size, resolution). It was also re-factored for better cloud-native functionality, incorporating some minor fixes, and containerised.

A continuous integration workflow (using GitHub Actions) was also developed and deployed with the application repository, which builds the container images and pushes them to a container registry repository at [Docker Hub](https://hub.docker.com/u/igrnt).

### 🏗️ Infrastructure & deployment

Two options are presented for automated provisioning of infrastructure and deployment of the application. One is a semi-monolithic deployment on an [EC2 compute instance](https://aws.amazon.com/ec2/) in [AWS](https://aws.amazon.com/); the other is a fully cloud-native, GitOps-style deployment on a [Kubernetes cluster](https://www.digitalocean.com/products/kubernetes) in [DigitalOcean](https://www.digitalocean.com/?refcode=56ab1cd93fe6).

#### 🐳 AWS EC2 deployment

The EC2 deployment uses [Terraform](https://www.terraform.io/) to declare and provision the cloud infrastructure, and [Ansible](https://www.ansible.com/) for system configuration management and application deployment.
The application is deployed as a multi-container service via [Docker Compose](https://docs.docker.com/compose/).

See [aws-ec2-docker/README.md](aws-ec2-docker/) for details and usage.

#### ☸ DigitalOcean Kubernetes deployment

The Kubernetes (K8s) deployment again uses [Terraform](https://www.terraform.io/) for cloud infrastructure provisioning, this time including a managed database service and object storage service bucket.
Terraform also bootstraps the k8s cluster with the [GitOps Toolkit](https://fluxcd.io/docs/components/) and [Flux](https://fluxcd.io/) controllers for continous delivery (CD) of the application lifecycle; Flux deploys the in-cluster infrastructure (incuding an external load balancer) and the application itself.

See [do-k8s-flux/README.md](do-k8s-flux/) for details and usage.
