## Build machine images

Machine images are used to make the process of orchestrating the application infrastructure faster since it prepackages the dependencies needed by the application to run eliminating the need of setting up the dependencies during orchestration.

Packer makes use of ansible as the provisioner. We chose ansible over the other provisioners is because of it's declarative approach to provisioning making the process easily repeatable and organised.

The current setup uses `ansible-vault` to encrypt secrets and the password has to be provided as a file before a packer build is run. Provide the password as a text-file named `.secret` inside the `packer` folder. This file is referenced by the `packer.json` file to retrieve the password.

To bake the machine images, navigate to the `Packer` directory, you will find a list of subdirectories which house the code required for provisioning the machine images for the different components of the architecture. In the root of the `Packer` directory, there should be `.secret` file containing the password needed by `ansible-vault` to decrypt the secrets. Ask the current/previous developers maintaining the project for the password.

If new secrets are to be added to the setup, please encrypt them with `ansible-vault` supplying the same password as the previous files before pushing the files to the remote repository. The `.secret` file shouldn't be commited to source control.

Below is a list of images to run packer against.

* **Frontend image**

To build machine images needed for the frontend deployments, follow the steps below.

```
export ENVIRONMENT=[environment]
export CREDENTIAL_FILE=[path-to-gcp-service-account-file]
make frontend-image
```
The packer configuration makes use of variables to build machine images for the different environments for example production/staging etc. Replace the variables below with their appropriate values.

Replace;

```environment ``` with the environment you want to build the images for, i.e: production or staging

```path-to-gcp-service-account-file``` with the path to your GCP service account file that has full access to Lenken project on GCP (project ID is lenken-app)

* **Backend api image**

To build machine images needed for the frontend deployments, follow the steps below.

```
export ENVIRONMENT=[environment]
export CREDENTIAL_FILE=[path-to-gcp-service-account-file]
make frontend-image
```
The packer configuration makes use of variables to build machine images for the different environments for example production/staging etc. Replace the variables below with their appropriate values.

Replace;

```environment ``` with the environment you want to build the images for, i.e: production or staging

```path-to-gcp-service-account-file``` with the path to your GCP service account file that has full access to Lenken project on GCP (project ID is lenken-app)

**NOTE:**
-

Both the lenken frontend and backend images make use of `nginx` for reverse proxying and compression to make the application run faster and save bandwidth. The images only expose port 80 for communication.

* **ELK image**
The ELK image is used to setup Elasticsearch, Logstash and Kibana. This image is where all the logs are sent from the production environment. To build machine image for ELK, follow the steps below:

```
export CREDENTIAL_FILE=[path-to-gcp-service-account-file]
make frontend-image
```

## Building the infrastructure

We are building the infrastructure on GCP using Terraform. Terraform helps us to write infrastructure as code so that it becomes easy for us to reproduce different environments using the same infrastructure. It also remembers the state of the infrastructure so that it can change and manage the infrastructure in an appropriate way. To build the infrastructure run the following commands:

```
export ENVIRONMENT=[environment]
export CREDENTIAL_FILE=[path-to-gcp-service-account-file]
make build
```

Replace;

```environment ``` with the environment you want to build the images for, i.e: production or staging

```path-to-gcp-service-account-file``` with the path to your GCP service account file that has full access to Lenken project on GCP (project ID is lenken-app)
