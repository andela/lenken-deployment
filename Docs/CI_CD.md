### Continous Integration/Continous Delivery Pipeline
The CI/CD pipelines on the frontend and backend are quite similar.

#### Continous Integration 
We use circleci version 2 for continous integration. 
##### Why circleci 2.0 over circleci 1.0
- CircleCI 2.0 includes a significant rewrite of container utilisation to run more jobs faster and to prevent available containers from sitting idle.
- In CircleCI 2.0, jobs are broken down into steps. This gives us the freedom and flexibility to run the build the way we want, since we can compose these steps to our own discretion.
- Jobs in version 2 support almost all public Docker images and custom images with our own dependencies.

#### Workflow for the frontend

circle ci file for frontend: <https://github.com/andela/lenken/blob/develop-v2/.circleci/config.yml>

In the workflow we have a number of jobs as listed below

- unit-tests
- end-to-end-tests
- deploy\_to\_staging
- Deploy\_to\_production

#### unit-tests

##### image
For this job we use a custom image from our project named **lenken-frontend** and tagged **test-env**. We use a custom image because circleci doesnot support node 7 which is being used on the lenken project.
	
	- image: gcr.io/lenken-app/lenken-frontend:test-env
##### parallelism
We use parallelism of 3, this means that our tests will be split into 3 different groups and each group will run on a different machine in parallel. This will ensure the tests run in 1/3 of the time.

##### steps in the unit-tests job

- **checkout** The repo is cloned from source control
- Installation of dependencies using `yarn install`
- Installation of codeclimate-test-reporter using `sudo yarn global add codeclimate-test-reporter`
- **save_cache** caches the installed dependencies. This helps to lower build time incase we re run the build.
- We run tests using `xvfb-run yarn test`

#### deploy\_to\_staging
This job is run only on the develop-v2 branch after the unit-tests job has succeeded.

##### image
For this job we use the google cloud sdk image, this is because we shall be running gcloud commands within the job.

```- image: google/cloud-sdk```

##### steps in the deploy\_to\_staging job
- **checkout** pull source code from source control
- The gcloud service key from environment variables is added to a file named auth\_lenken\_app.json, this will be used for authentication against gcloud.
- We deploy using deploy_lenken.sh script

#### deploy.sh 

The scripts contains three functions

- configure_gcloud : This function authenticates gcloud with gcp using the `auth_lenken_app.json` key file created in an earlier step. We also set the project and compute zone corresponding to our gcp infrastructure.
- deploy_change : This function adds the current build commit to the project metadata and perform a rolling replace on the `staging-lenken-frontend-group-manager.` A rolling replace will incrementally replace instances in the instance group with new ones having the updated configuration. This is done in such a way that you have no application downtime since the replcement is incremental.
- main runs configure_cloud and deploy_change in sequence.

### Workflow for the backend

circleci file for the backend: <https://github.com/andela/lenken-server/blob/develop/.circleci/config.yml>

In the workflow for the backend there are the following jobs:

- build
- deploy\_to\_staging
- deploy\_to\_production

#### Build

##### Image
In the build job we use three images from circleci `circleci/php:7.1-browsers` for php and `circleci/postgres:9.6` for postgres and `redis` for the redis server.

##### Steps in the build job 
- Install php extensions needed for connecting to the postgresql database.
- Install Composer.
- Checkout pulls the source code from the github repository.
-  Restore_cache restores cache if the job has been previously run, this makes installation of dependencies quicker and reduces build times incase the job is being rerun.
-  Composer install dependencies installs project dependencies using composer. The no-interaction flag allows the installations to continue without any prompts. `composer install --prefer-dist --no-interaction`

-   Composer Test runs the tests
-   Test coverage reporter, runs the codeclimate test-reporter `vendor/bin/test-reporter` this requires providing the code climate repo token.

#### deploy\_to\_staging
This job uses `/tmp/lenken` as the working directory meaning that is where the repository will be cloned to.

##### image
The google/cloud_sdk image is used since the deployment will involve running gcloud commands.

##### Steps in the deploy\_to\_staging
- Checkout clones the repository to tmp/lenken
- Add Gcloud key json file echos the gcloud service key to auth_lenken_app json file, this will help to authenticate against gcp
- Deploy to Production GCP Vms runs deploy_lenken.sh script which in turn does the deployment to gcp.

##### deploy_lenken.sh
Like deploy.sh in the frontend, deploy_lenken.sh has three functions as elaborated below:

- configure_gcloud: function authenticates to gcp using the lenken_app_json file created earlier. Also sets the project and compute zone to correspond to the infrastructure on gcp.
- deploy_change: function adds the current build commit to the project metadata and performs a rolling replace on the `staging-lenken-api-group-manager` 
- main runs configure\_cloud and deploy\_change in sequence.
