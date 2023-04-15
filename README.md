# tx-interview

This repository contains code for the interview assignment that is a part of the recruitment process for a DevOps role at TX Services.

Here I cover:

1. General overview
2. Application overview
3. Infrastructure overview

## General Overview

The requirements can be found in the [requirements.pdf](https://github.com/BogdanBozic/tx-interview/requirements.pdf) file, so I will not go over that here.

From the root directory one must provide the variables specified in the variables.tf file and run `terraform apply` in order to build everything up. That will:

1. Build up the infrastructure in AWS that mainly consists of an EKS cluster with its worker node group and the necessary resources for it to run properly
2. Build a "jump server" that serves as a simulation of GitOps approach in this simplified environment
3. Build the application repository on Github

To tear everything down, don't think twice - use `terraform destroy --auto-approve` from the root directory and watch everything burn.

## Application Overview

The application is a simple Python FastAPI app that returns a string when hit with a GET request. The public facing URL is [goldbach.bastovansurcinski.click](goldbach.bastovansurcinski.click). As the name suggests, you should click on it. 

![](assets/do_it)

After the whole project has been created as explained above, this app will be stored in [this repo](https://github.com/BogdanBozic/bogdan_goldbach_app_repo). If the repo doesn't exist at the moment, that means that I have tore everything down to save some money.

The repository has Github Actions CI implemented and it also serves as CD along with the "jump server" that I will talk about later. The CI consists of two jobs:

1. Test - runs Python lint, Dockerfile lint, unit tests
2. Deploy - Builds and publishes the image to the Docker Hub, stores the hash in a file that is transferred as an artifact to the "jump server" and then an SSH script is executed that updates the application deployment manifest located on the "jump server" and triggers the deployment of the new app version

## Infrastructure Overview

### Terraform code

#### Infrastructure

The center of the infrastructure is the AWS EKS cluster and its worker node group. Everything in the `tf/modules/kubernetes` directory, save for jump_server.tf and null_resources.tf is related to it. IAM roles and permissions, VPC (subnets, internet gateway, NAT gateways, route tables), Security Groups.

In other words, Terraform here is used only to build the infrastructure necessary for the cluster to run properly. All the cluster configuration is done through Helm and kubectl from the "jump server", even though it's mostly been automated using Terraform.

#### Automated provisioning of the cluster resources

When I first started bulding the project I had imagined this as a template that would be usable by others as well. As I was realising I'm running out of time, I decided to cut the story short and so the "jump server" came to life. It serves as a simulation of the GitOps approach as and such I wouldn't use it in production environments.

An overview of the infrastructure setup looks like this:

1. Terraform builds EKS and its necessary components on AWS
2. Terraform provisons the "jump server" EC2 instance and installs tools for managing the cluster and installs the resources
3. The public IP of the server is passed to the Application module so CI would know where to SSH to

---

So the "jump server" serves as the provisioner, destroyer and maintainer of the kubernetes resources and it is the one handling the app image update for new deployments.

It is set up by the null_resource resources in Terraform. They:

1. Transfer the files to the server
2. Install the necessary dependencies like AWS cli, Helm, Git, kubectl
3. Create the necessary kubernetes resources, like app deployment and its service, cert-manager, nginx ingress controller with an AWS NLB and its ingress
4. Create a DNS record in Route53 for the newly created LB

All the manifests and configuration files are located in `/home/ec2-user/k8s_resources/` on the server so destroying all the kubernetes resources can be done with 'kubectl delete -f .' from that directory and 'helm delete nginx-ingress && helm delete cert-manager', since the two have been created using Helm. All of this will be done automatically once 'terraform destroy' has been called from the root directory of the repository as it is a part of the remote-exec provisioner of the EC2 instance serving as the "jump server". Otherwise, Terraform wouldn't be able to delete resources that it doesn't have definitions of, like the NLB.

#### Networking

Networking in this case looks like this: 

![](assets/networking)

I stole this image from [here](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-end-to-end-encryption-for-applications-on-amazon-eks-using-cert-manager-and-let-s-encrypt.html) as it perfectly
