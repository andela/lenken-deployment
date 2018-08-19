## INFRASTRUCTURE
Lenken application comprises of two repositories; one for the frontend and the other for the backend. This information was taken into consideration while planning the infrastructure. The schema of the overall Lenken infrastructure on GCP is depicted in the diagram below:


![Lenken Infrastructure](https://github.com/andela/lenken-deployment-scripts/blob/ch-document-project-readme-156068504/Docs/images/lenken_infrastructure.png?raw=true)
##### Fig 1.0 Lenken Infrastructure Setup on Google Cloud Platform

Lenken infrastructure was implemented on GCP with Terraform which is an Infrastructure as Code tool. Custom images for the frontend, api backend and redis server were built using packer and ansible. The purpose of this document therefore, is to describe each of the block and the process taken to actualize it. To achieve this, we shall be having an in depth look at the terraform scripts used in setting up the infrastructure.

The Terraform directory can be found inside the parent directory in the lenken-deployment-script repo. The structure of the repo is shown below:

* Lenken-deployment-script
  * Dockerfiles
  * Kubernetes
  * Packer
  * Terraform

The Terraform folder contains all the script used in setting up the Lenken infrastructure on GCP

### main.tf
The main script file contains the initialization of the cloud platform we are making use of. In our own case, we are making use of the Google Cloud Platform (GCP). There are three blocks in this file:

* ***Provider block*** initializes the cloud provider (google in our own case), the credentials, the project and the region of the project on the cloud platform. The credential field in the provider block is supplied with the correct service account key which MUST NOT be pushed to the github or any version control tool used. The service account key is placed in a separate folder called the shared and it is ignored in the .gitignore file. Ensure you provide the service key when you clone this repository. 
* ***Terraform backend*** configures the setup to be making use of google cloud storage (gcs) for storing the tfstate file. This ensures that the tfstate file which is a file generated for keeping track of current state of the infrastructure is not residing on one person’s system. Also, it ensures that it is secured and distributed team can work on the same infrastructure.
* ***Data terraform_remote_state*** retrieves the terraform state file from the remote storage whenever terraform apply or terraform destroy command is executed. In the configuration, the bucket, project and credential for login to the remote storage should be specified.

### network.tf
From the schematic above, it is shown that we have two subnets in our network; the private and the public subnet. Instances in the private subnet do not have direct access to the internet. They only reach the internet through the NAT gateway while instances in the public subnet have direct access to the internet. In the network.tf file, we defined the network, the subnets, and the routing (for NAT instances). The private subnet has the IP range of ***10.0.1.0/24*** as specified in the variable.tf file. The public subnet has a different IP range which is ***10.0.2.0/24***. Both the private and the public subnet belong to the same network.
The route used by the NAT server is defined here. The NAT server is used by instances in the private subnet to access the internet. In the definition of the route in the network.tf file, the destination IP range is ***0.0.0.0/0*** to specify anywhere in the internet. Also the next hop instance is the NAT server.

### routing.tf
This file contains the ***google_compute_global_forwarding_rule*** for port 80 (http) and 443(https) respectively. The global forwarding rules provides a single IP for a target http(s) proxy.

The global forwarding rule has the application reserved ip address, the port range (80 and 443 in our case) and the target http proxy.

The ***google_compute_target_http_proxy*** and ***google_compute_target_https_proxy*** both point to one google_compute_url_map which is a resource that point to a backend service based on the incoming request. 

In our own case, we have [lenken-staging-test.andela.com](https://lenken-staging-test.andela.com) pointing to ***lenken-frontend-backendservice*** and [lenken-api-staging.andela.com](https://lenken-api-staging.andela.com) pointing to lenken-api-backendservice. 

***Google_compute_ssl_certificate*** is used to specify the ssl certificate used in this setup. The SSL certificate is contained in ***./shared*** folder and ***MUST NOT*** be committed to the repository.

***Google_compute_firewall*** is used to create the following firewall rules as contained in the file:

* ***Lenken-internal-firewall*** to allow icmp, tcp and udp for all instances in the private subnet
* ***Lenken-public-firewall*** to allow tcp 80 and 443 for all incoming request from everywhere ***0.0.0.0/0***. This rule is attached to the Load balancer.
* ***Firewall_api_allow_http*** to allow http access
* ***Firewall_api_allow_https*** to allow https access
* ***Lenken-allow-redis*** to allow tcp 6379 rule for redis server
* ***Lenken-nat-ingress*** and ***lenken-nat-egress*** for allow NAT ingress and egress rule
* ***Lenken-allow-ssh*** to allow ssh rule for the instances
* ***Lenken-allow-healthcheck-firewall*** to allow firewall rule for the health checks used by the load balancer


### redis.tf
The redis server is required in the Lenken application for caching. This file sets up the instance with already baked image of redis ***(lenken-redis-image)***. The private IP ***10.0.1.6*** is assigned to this instance from the subnet because it is used in the application to reference the redis server. This instance has the following firewall rules: ***allow-redis, private-instance, allow-internal, allow-ssh, http-server and https-server***


### nat.tf
As depicted in the diagram, the NAT serves as an avenue through which instances in the private subnet (ie instances without public ip) communicate with the internet. The NAT server sits in the public subnet and has public IP address that is reserved. The IP forwarding rule is set to true to guide the packets to its destination. In IP table masquerading is done in the startup script ***(metadata_startup_script)*** to allow this instance act on behalf of the private instances in accessing the internet.

### compute.tf
The compute.tf file contains the instance templates, instance groups, the instance, the instance backend service, the auto scaler and the health checks for the frontend and the backend. 

* ***Google_compute_instance_template*** creates the frontend and the backend templates using the custom baked images specified during the creation time. The firewall rule tags are specified in the instance template so that instances created off this templates will automatically inherit those rules. Also, the frontend and backend are created in the private subnets.
* ***Google_compute_instance_group_manager*** uses the instance template to create the instance group. The instance group manager makes it possible for all instances created off the template to be managed together given that they are similar. In our own case, we have the instance group manager for frontend and backend respectively.
* ***Google_compute_backend_service*** creates the backend services off the instance group manager. The backend services is used while setting up the load balancer to direct traffic to a specific instance group. The backend service has a health check that is uses to check the health of the instances in the instance group.
* ***Google_compute_health_check*** is used to create the health check used by the backend services. In this resource, we specified that the ***healthy_threshold*** of the instances in the instance group should be 2. This implies that we only have two healthy instances running at any given time. 
* ***Google_compute_autoscaler*** attached to the instance group manager is used to automatically create a new instance when the CPU usage of another instance is above 70%. The maximum instance we can have in a group is 4 while the minimum instance is 2. This is same for both the frontend and the backend.

### database.tf
At the point of writing this documentation, we currently make use of the GCP SQL option for creating postgres database. The database data is exported manually from the current platform on Heroku addon using 

***pg_dump --no-privileges --quote-all-identifiers --no-acl --no-owner postgres url | grep -v -E '(CREATE\ EXTENSION|COMMENT\ ON)' > lenken_test_backup.sql***. 

The backup file is uploaded to the Google Cloud Storage (gcs) from where it is imported to the database instance created in GCP SQL.


