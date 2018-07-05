## Build machine images

Machine images are used to make the process of orchestrating the application infrastructure faster since it prepackages the dependencies needed by the application to run eliminating the need of setting up the dependencies during orchestration.

Packer makes use of ansible as the provisioner. We chose ansible over the other provisioners is because of it's declarative approach to provisioning making the process easily repitable and organised.

The current setup uses `ansible-vault` to encrypt secrets and the password has to be provided as a file before a packer build is run. Provide the password as a textfile named `.secret` inside the `packer` folder. This file is referenced by the `packer.json` file to retrieve the password.

To bake the machine images, navigate to the `Packer` directory, you will find a list of subdirectories which house the code required for provisioning the machine images for the different components of the architecture. In the root of the `Packer` directory, there should be `.secret` file containing the password needed by `ansible-vault` to decrypt the secrets. Ask the current/previous developers maintaining the project for the password.

If new secrets are to be added to the setup, please encrypt them with `ansible-vault` supplying the same password as the previous files before pushing the files to the remote repository. The `.secret` file shouldn't be commited to source control.

Below is a list of images to run packer against.

* **Frontend image**

To build machine images needed for the frontend deployments, follow the steps below.

```
#Navigate to the directory containing the frontend image packer configuration
cd Packer/frontend
#run packer to build the image
packer build -var 'project_id=_put_project_id_here' -var 'commit_id=_put_commit_id_here' -var 'environment=_put_environment_here -force packer.json
```
The packer configuration makes use of variables to build machine images for the different environments for example production/staging etc. Replace the variables below with their appropriate values.

Replace;

```_put_project_id_here ``` with the project id for example `lenken-app`

```_put_commit_id_here``` with the commit id or branch for example `develop-v2` for the staging environment.

```_put_environment_here``` with the name of the environment the image will be deployed to for example `staging` to build machine images for the staging environment.

* **Backend api image**

To build machine images needed for the frontend deployments, follow the steps below.

```
#Navigate to the directory containing the frontend image packer configuration
cd Packer/backend-api
#run packer to build the image
packer build -var 'project_id=_put_project_id_here' -var 'commit_id=_put_commit_id_here' -var 'environment=_put_environment_here -var 'new_relic_licence=_new_relic_licence` -var 'new_relic_app=_new_relic_app` packer.json 
```
The packer configuration makes use of variables to build machine images for the different environments for example production/staging etc. Replace the variables below with their appropriate values.

Replace;

```_put_project_id_here ``` with the project id for example `lenken-app`

```_put_commit_id_here``` with the commit id or branch for example `develop` for the staging environment and `master` for `production`.

```_put_environment_here``` with the name of the environment the image will be deployed to for example `staging` to build machine images for the staging environment and `production` to build images for the production environment.

```_new_relic_licence``` with the new relic licence number to activate new relic monitoring.

```_new_relic_app``` with the name that will be used to monitor the application on new relic.

**NOTE:**
-

Both the lenken frontend and backend images make use of `nginx` for reverse proxying and compression to make the application run faster and save bandwidth. The images only expose port 80 for communication.


* **Postgresql image**

The postgres image is used to spin up postgres instances for database storage.

```
#Navigate to the postgres directory
cd Packer/postgres
#Run packer to build the image
packer build packer.json
```

* **Redis image**

The redis image is used to spinup redis instances for caching requests made by the application.

```
#Navigate to the redis directory
cd Packer/redis
#Run packer to build the image
packer build packer.json
```

**Orchestrate the infrastructure**
-

