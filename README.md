# Terraform gcp scheduler cloudrun

This application will help you in creating gcp cloud run service via terraform. 

### Why to choose - Cloud run for scheduling jobs ? 
While designing applications (specially microservices based) we got into the situation to create some back-office kind utility which 
do some kind of cleaning jobs based on specific schedules. 

To handle such problems developers either create scheduling jobs in some of the microservice or create new module. Prefer later one where they could
keep adding utilities based on the business domain. In one of my previous project we called it backoffice processor, which used to process some of the operation on 
specific time it could be related to business or could be not. For ex: Send customer notifications between 9 am only , data push to start pushing data.
Check some of the best suitable use-casess here. https://cloud.google.com/run#section-10


Here we will set up 


![webhook details](images/webhook-details.png)



### Let's build microservice image

```
$ mvn clean install -f weather-service/pom.xml
```

### Tag and Push image
```
$ docker tag sample-microservice/weather-service gcr.io/api-project-808184727589/ms1
$ docker push gcr.io/api-project-808184727589/ms1
```

### Terraform resource - Cloud Run  
```
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "gcr.io/api-project-808184727589/ms1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
```
It will create cloud run service of ms1 running container will start serving 100% traffic.  


### Create Scheduler job 
````
resource "google_cloud_scheduler_job" "job" {
  name             = "report-generation-job"
  description      = "report generation job"
  schedule         = "*/2 * * * *"
  time_zone        = "America/New_York"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = "https://example.com/ping"
  }
}
````


#### Initialize 
```
terraform init
```

#### Apply changes.
```
terraform apply
```





#### Destory 
```
terraform destroy
```


Login

```
WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ gcloud auth login --no-launch-browser
Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth?code_challenge=cpp2nNoREsHpJrgyS8FP5xoPaHDKVZZg4WD3SU8ozhY&prompt=select_account&code_challenge_method=S256&access_type=offline&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth


Enter verification code: 4/0wHx2zN3OSAzpKCwqJsa8stCdKNYMmVEnd26Ka1YxFOEQA96Kzwm-p8

You are now logged in as [ritresh.girdhar@gmail.com].
Your current project is [api-project-808184727589].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID

```

```
gcloud config set project api-project-808184727589
Updated property [core/project].




WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ terraform init 

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```


```
WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ terraform apply
 data.google_iam_policy.noauth: Refreshing state...
 google_cloud_run_service.weather-service: Refreshing state... [id=locations/us-central1/namespaces/loblaw-280320/services/weather-service]
 
 An execution plan has been generated and is shown below.
 Resource actions are indicated with the following symbols:
   + create
 -/+ destroy and then create replacement
 
 Terraform will perform the following actions:
 
   # google_cloud_run_service.weather-service is tainted, so must be replaced
 -/+ resource "google_cloud_run_service" "weather-service" {
       ~ id       = "locations/us-central1/namespaces/loblaw-280320/services/weather-service" -> (known after apply)
         location = "us-central1"
         name     = "weather-service"
       ~ project  = "loblaw-280320" -> (known after apply)
       ~ status   = [
           - {
               - conditions                   = [
                   - {
                       - message = "Google Cloud Run Service Agent must have permission to read the image, gcr.io/api-project-808184727589/ms1. Ensure that the provided container image URL is correct and that the above account has permission to access the image. If you just enabled the Cloud Run API, the permissions might take a few minutes to propagate. Note that the image is from project [api-project-808184727589], which is not the same as this project [loblaw-280320]. Permission must be granted to the Google Cloud Run Service Agent from this project."
                       - reason  = "ContainerPermissionDenied"
                       - status  = "False"
                       - type    = "Ready"
                     },
                   - {
                       - message = "Google Cloud Run Service Agent must have permission to read the image, gcr.io/api-project-808184727589/ms1. Ensure that the provided container image URL is correct and that the above account has permission to access the image. If you just enabled the Cloud Run API, the permissions might take a few minutes to propagate. Note that the image is from project [api-project-808184727589], which is not the same as this project [loblaw-280320]. Permission must be granted to the Google Cloud Run Service Agent from this project."
                       - reason  = "ContainerPermissionDenied"
                       - status  = "False"
                       - type    = "ConfigurationsReady"
                     },
                   - {
                       - message = "Google Cloud Run Service Agent must have permission to read the image, gcr.io/api-project-808184727589/ms1. Ensure that the provided container image URL is correct and that the above account has permission to access the image. If you just enabled the Cloud Run API, the permissions might take a few minutes to propagate. Note that the image is from project [api-project-808184727589], which is not the same as this project [loblaw-280320]. Permission must be granted to the Google Cloud Run Service Agent from this project."
                       - reason  = ""
                       - status  = "Unknown"
                       - type    = "RoutesReady"
                     },
                 ]
               - latest_created_revision_name = "weather-service-trhrx"
               - latest_ready_revision_name   = ""
               - observed_generation          = 1
               - url                          = ""
             },
         ] -> (known after apply)
 
       ~ metadata {
           ~ annotations      = {
               - "serving.knative.dev/creator"      = "terraform@loblaw-280320.iam.gserviceaccount.com"
               - "serving.knative.dev/lastModifier" = "terraform@loblaw-280320.iam.gserviceaccount.com"
             } -> (known after apply)
           ~ generation       = 1 -> (known after apply)
           ~ labels           = {
               - "cloud.googleapis.com/location" = "us-central1"
             } -> (known after apply)
           ~ namespace        = "loblaw-280320" -> (known after apply)
           ~ resource_version = "AAWoEPTo8Hg" -> (known after apply)
           ~ self_link        = "/apis/serving.knative.dev/v1/namespaces/51523235489/services/weather-service" -> (known after apply)
           ~ uid              = "6915c239-bcfb-4924-8c8e-cfd1de03d276" -> (known after apply)
         }
 
       ~ template {
           - metadata {
               - annotations = {
                   - "autoscaling.knative.dev/maxScale" = "1000"
                 } -> null
               - generation  = 0 -> null
               - labels      = {} -> null
             }
 
           ~ spec {
               - container_concurrency = 80 -> null
               + serving_state         = (known after apply)
 
               ~ containers {
                   - args    = [] -> null
                   - command = [] -> null
                   ~ image   = "gcr.io/api-project-808184727589/ms1" -> "gcr.io/loblaw-280320/ms1"
 
                   - resources {
                       - limits   = {
                           - "cpu"    = "1000m"
                           - "memory" = "256Mi"
                         } -> null
                       - requests = {} -> null
                     }
                 }
             }
         }
 
       ~ traffic {
             latest_revision = true
             percent         = 100
         }
     }
 
   # google_cloud_run_service_iam_policy.policy will be created
   + resource "google_cloud_run_service_iam_policy" "policy" {
       + etag        = (known after apply)
       + id          = (known after apply)
       + location    = "us-central1"
       + policy_data = jsonencode(
             {
               + bindings = [
                   + {
                       + members = [
                           + "allUsers",
                         ]
                       + role    = "roles/run.invoker"
                     },
                 ]
             }
         )
       + project     = (known after apply)
       + service     = "weather-service"
     }
 
 Plan: 2 to add, 0 to change, 1 to destroy.
 
 Do you want to perform these actions?
   Terraform will perform the actions described above.
   Only 'yes' will be accepted to approve.
 
   Enter a value: yes
 
 google_cloud_run_service.weather-service: Destroying... [id=locations/us-central1/namespaces/loblaw-280320/services/weather-service]
 google_cloud_run_service.weather-service: Destruction complete after 3s
 google_cloud_run_service.weather-service: Creating...
 google_cloud_run_service.weather-service: Still creating... [10s elapsed]
 google_cloud_run_service.weather-service: Still creating... [20s elapsed]
 google_cloud_run_service.weather-service: Still creating... [30s elapsed]
 google_cloud_run_service.weather-service: Still creating... [40s elapsed]
 google_cloud_run_service.weather-service: Still creating... [50s elapsed]
 google_cloud_run_service.weather-service: Creation complete after 57s [id=locations/us-central1/namespaces/loblaw-280320/services/weather-service]
 google_cloud_run_service_iam_policy.policy: Creating...
 google_cloud_run_service_iam_policy.policy: Creation complete after 3s [id=v1/projects/loblaw-280320/locations/us-central1/services/weather-service]
 
 Apply complete! Resources: 2 added, 0 changed, 1 destroyed.
 
 Outputs:
 
 url = https://weather-service-bmgsrd6uza-uc.a.run.app



```


```
gcloud iam service-accounts list
NAME       EMAIL                                                       DISABLED
terraform  terraform@api-project-808184727589.iam.gserviceaccount.com  False
```

```
WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ gcloud auth activate-service-account terraform@api-project-808184727589.iam.gserviceaccount.com --key-file=./api-project-808184727589-de8a32ba6bc5.json
Activated service account credentials for: [terraform@api-project-808184727589.iam.gserviceaccount.com]
```

```
docker login -u _json_key -p "$(cat ./loblaw-280320-9e0236ac2d5c.json)" https://gcr.io
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ docker push gcr.io/loblaw-280320/ms1:latest

WKMIN1307242:terraform-gcp-scheduler-cloudrun ritgirdh$ docker push gcr.io/loblaw-280320/ms1:latest
The push refers to repository [gcr.io/loblaw-280320/ms1]
18872ac8915d: Pushed 
ceaf9e1ebef5: Pushed 
9b9b7f3d56a0: Layer already exists 
f1b5933fe4b5: Layer already exists 
latest: digest: sha256:42d95b4872c1ddb8bd5b8a44ddf8d79f989915b4a1bec7aecbdfd893c6329630 size: 1159


```