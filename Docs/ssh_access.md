### SSH ACCESS

SSH Access allows a secure access to our server on GCP. For one to have the privilege of making the secure connections to our instances, one need to have been added to the Lenken project on GCP and IAM role sufficient for this role created for him. Secure connection to the instances can be made from the ***Google console*** or from the local terminal with ***gcloud*** installed.

### SSH Access from the terminal using gcloud

* [Install gcloud sdk](https://cloud.google.com/sdk/downloads) on your local machine
* Run ***gcloud init*** to perform the initial setup tasks. You can also run gcloud init at a later time to change your settings or create a new configuration.
When the configuration is done, you can now run gcloud commands on your local terminal
* To access the instances running on the private subnet, you first need to SSH into the NAT server with this command gcloud compute --project "lenken-app" ssh --zone "europe-west1-b" "staging-lenken-nat-server". When in the instance, you can now ssh into any of the private instances.
*To view all the instances in the lenken project, run gcloud compute instances list.

### SSH Access from the Google Console

* Log into Google console with your valid account
* Select the lenken project from the dropdown showing all the available projects
* Click on the Compute Engine from the sidebar or type and select Compute Engine from the search box
* Click on the SSH button of the staging-lenken-nat-server and select open in browser window option. 
* You can now ssh into other instances from the staging-lenken-nat-server.

##### NB: Ensure you close all connection to the cloud server after every activity. This is to ensure that an unauthorized user who have access to your system cannot tamper with the infrastructure.
