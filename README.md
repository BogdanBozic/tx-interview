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

So the "jump server" serves as the provisioner, destroyer and maintainer of the kubernetes resources and it is the one handling the app image update for new deployments. The Terraform resource itself has several dependencies that make sure that the instance will be able to reach the cluster before it's destroyed.

It is set up by the null_resource resources in Terraform. They:

1. Transfer the files to the server
2. Install the necessary dependencies like AWS cli, Helm, Git, kubectl
3. Create the necessary kubernetes resources, like app deployment and its service, cert-manager, nginx ingress controller with an AWS NLB and its ingress
4. Create a DNS record in Route53 for the newly created LB

All the manifests and configuration files are located in `/home/ec2-user/k8s_resources/` on the server so destroying all the kubernetes resources can be done with 'kubectl delete -f .' from that directory and 'helm delete nginx-ingress && helm delete cert-manager', since the two have been created using Helm. All of this will be done automatically once 'terraform destroy' has been called from the root directory of the repository as it is a part of the remote-exec provisioner of the EC2 instance serving as the "jump server". Otherwise, Terraform wouldn't be able to delete resources that it doesn't have definitions of, like the NLB.

#### Networking

Networking in this case looks like this: 

![](assets/networking)

I stole this image from [here](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-end-to-end-encryption-for-applications-on-amazon-eks-using-cert-manager-and-let-s-encrypt.html) as it perfectly matches my use case.

The EKS Cluster is in two public subnets, and it is exposed by an Internet Gateway to the IP that runs `terraform apply` only. The worker node group is in two public subnets that I have exposed to the public using the NAT gateway linked to the public subnets where the cluster resides and its IG. Too late have I realised that the communication between the cluster and the nodes actually goes through that NAT Gateway. As one of the weaknesses of the system I would like to point this one out, as it could have been built with a VPC Endpoint for those purposes.

The "jump server" is exposed to the public, but only on port 22 for SSH connections, and it's in the same VPC as the other two.

#### TLS

TLS is managed by cert-manager that's using Let's Encrypt. This approach is the only one that I'm aware of that doesn't require any manual intervention at any time, nor does it require any additional resources to work, like cronjobs and stuff.

Cert-manager is installed on the cluster by the "jump server" once the cluster is up and running. 

## Startup flow

The whole startup flow looks like this:

1. When `terraform apply` is run from the repo root, Terraform starts building the infrastructure module first.
* Terraform builds its own dependency graph, so I will not go into much detail here
* The only notable point is that the "jump server" goes last, followed only by the provisioning null_resources as we need everything set up before we can provision kubernetes resources
2. On the Kubernetes side, the provisioners will install the necessary dependencies (Helm, kubectl, AWS cli, yq, jq...) and resources afterwards (app deployment and service, cert-manager, Nginx ingress controller, ingress...) and it will build a Route53 record for goldbach.bastovansurcinski.click that the app will use
2. After that is done, the application repo is built. It has to be the last one because building it triggers Github Actions workflow that needs the public IP of the "jump server". I have injected a dependency in the description of the Github repository resource - it's waiting for the "jump server" id. A dirty, yet working solution.
3. The repo will, thus, trigger Github Actions workflow as it will receive a "push" notification and the workflow will build the "latest" app image update the kubernetes deployment of the app with it

## Weaknesses

1. As mentioned above, worker node group communicates through public internet with the cluster. Can be solved with a VPC Endpoint.
2. The "jump server". It is meant to serve only as a simulation of the GitOps approach. So:
* We should never SSH from any CI into anywhere but use webhooks instead.
* Could have changed the port from 22 to something else. Not really a security feature, but I guess it would prevent at least some attempts to ssh through 22.
* Using webhooks would require a service that would be listening for them and acting accordingly, so that's missing as well.
* Tools like ArgoCD could have been used for maintaining the apps.
* An additional Github repo for the infrastructure containing app versions with Helm charts could have been used to further automate and make the platform more resilient.
* The server itself is a single EC2 machine without any persistent block storage, so if anything goes wrong with it - we loose everything.
* The server is using a default Amazon Linux 2 AMI, meaning that if something goes wrong, we would have to install everything from the scratch and build the files anew. A custom image with the tools pre-built could have been used with some persistent storage within the Kubernetes cluster itself.
3. The remote state file is held locally. I didn't want to have it stored anywhere else as it is only an assignment project, but this approach should never be used anywhere.
4. I didn't use any external secret managers.
5. The infrastructure is not as templetisized (I'm pretty sure that's not a real word), meaning that if we were to add more applications to it we would need to manually adjust the infrastructure to support it.

## My experience using ChatGPT

When I talked to Damir, I was heavily criticised for not utilising the possibilities ChatGPT offers. As a part of the assignment we have agreed that I start using it and have it tested to see how useful it can get.

I must say it is a rather different experience than using a standard search engine. What amazed me the most, maybe, is the ability of the Bot to comprehend the conversation and not only focus on the question placed before it. 

When it comes to the information that I was able to get out of it, there are a few things I realised:

1. It doesn't (yet) understand how some things work, but interprets what he finds somewhere. Whatever the cognitive flow of its was, at some point it claimed NLB to be working on the level 7, and the ALB to be working on the level 4.
2. It cannot be used to get explanation on a complex question or a solution. When I say complex, I mean that it consists of several components. So, for example, it wouldn't be able to tell me how would I need to make my setup so that I can use cert-manager in my k8s cluster.
3. What it can do is answer more simple and straight-forward questions, like what is cert-manager and how does it work. 
4. To combine the previous two, you could actually build up the conversation by asking it questions one by one and making it learn along the way, so it could tell you more.
5. Same stands for when asking for code snippets. It will not be able to write some complex code at first (or at all), but you can help it by gradually increasing the complexity starting from simple questions.
6. It doesn't work well with writing declarative code. When providing samples for Terraform resources or Kubernetes manifests, it will often mix things that cannot go together or have been deprecated quite some time ago.
7. What it does brilliantly is writing and validating linear lines of code like in Bash. It really excels there.
8. A thing that amazed me is that I asked it to run Hadolint against my Dockerfile - and it did. The output wasn't really as the one I had gotten, but it did give me some valid results.
