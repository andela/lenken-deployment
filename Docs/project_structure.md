## Repository Structure

The project is divided into two main branches; ***master*** and ***develop***.

**Master Branch**

The master branch is the stable branch housing code to setup the production infrastructure. Before changes are merged to this branch, they have to be stress tested on the develop branch for any flaws and loopholes.


**Develop Branch**

The develop branch has bleeding edge changes to the infrastructure code used to make deployments to the ***lenken-staging-test*** where new changes are stress tested before being merged to master.

**Feature Branch**

A feature/chore and bug branches in the format of ***ft-name-of-feature***, ***ch-name-of-chore*** and ***bug-name-of-bug*** will be branched off the develop  and when it is ready, a PR raised should be raised to make updates to the **develop** branch.

## Project directory structure

The project is divided into several directories each holding separate components needed to orchestrate or provision the architecture.

```
project directory
│   README.md
└───Terraform  
└───Packer
└───Kubernetes
└───Dockerfiles
```

* **Terraform:** Contains terraform scripts needed to orchestrate the infrastructure ie. setup load balancers, instance groups, firewall rules etc.
* **Packer:** Contains scripts packer and ansible scripts for provisioning machine images to be used to deploy instances needed to provision the infrastructure.
* **Kubernetes:** Contains configurations for setting up lenken on kebernetes
* **Dockerfiles:** Contains dockerfiles for creating custom docker images to be used for running builds and unittests on circleci.
