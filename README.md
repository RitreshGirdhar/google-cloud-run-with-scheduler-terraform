# Google cloud + Google scheduler - set up via Terraform

This application will help you in creating google cloud service which will be invoke by google cloud scheduler. Will set up both services via terraform. 

### Why to choose - Cloud run for scheduling jobs ? 
While designing applications (specially microservices based) we got into the situation to create some back-office kind utility which 
do some kind of cleaning jobs based on specific schedules. 

To handle such problems developers either create scheduling jobs in some of the microservice or create new module. 
Prefer later one where they could keep adding utilities based on the business domain. In one of my previous project we called it backoffice processor, which used to process some of the operation on 
specific time it could be related to business or could be not. 

For ex: Send customer notifications between 9 am only , data push to start pushing data.
Check some of the best suitable use-casess here. https://cloud.google.com/run#section-10

Here we will set up Cloud Run and scheduler via Terraform. Scheduler will invoke jobs running on cloud run via making secure http call. From security point of view we will enable 
OIDC token 

### Create Project
![Create project](images/create-project.png)

![Project created](images/project-created.png)

### Create Service account 

![Project created](images/sa-1.png)
![Project created](images/sa-2.png)
![Project created](images/sa-3.png)
![Project created](images/sa-4.png)
![Project created](images/sa-5.png)

### Enable Container registry
![Project created](images/enable-container-registry.png)

### Let's build microservice image

```
$ mvn clean install -f report-generator-service/pom.xml
```
#### Create tag
```
$ docker tag demo/report-generator-service:latest gcr.io/charged-library-280615/report-generator-service:latest
```

### Login to google container registry Tag
```
$ docker login -u _json_key -p "$(cat ./charged-library-280615-9fa9b79158d5.json)" https://gcr.io
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```
### Push docker image
```
$ docker push gcr.io/charged-library-280615/report-generator-service:latest 
The push refers to repository [gcr.io/charged-library-280615/report-generator-service]
035c61f5476b: Preparing 
ceaf9e1ebef5: Preparing 
9b9b7f3d56a0: Preparing 
f1b5933fe4b5: Preparing 
denied: Token exchange failed for project 'charged-library-280615'. Caller does not have permission 'storage.buckets.create'. To configure permissions, follow instructions at: https://cloud.google.com/container-registry/docs/access-control
```

### Enable Cloud storage
![Project created](images/enable-cloud-storage.png)

### Create bucket
![Project created](images/bucket-1.png)
![Project created](images/bucket-2.png)
![Project created](images/bucket-3.png)
![Project created](images/bucket-4.png)
![Project created](images/bucket-5.png)
![Project created](images/bucket-6.png)

### Define permision to access bucket
![Project created](images/Update-cloud-storage-permission.png)

### Again Push docker image
```
$ docker push gcr.io/charged-library-280615/report-generator-service
The push refers to repository [gcr.io/charged-library-280615/report-generator-service]
035c61f5476b: Pushed 
ceaf9e1ebef5: Layer already exists 
9b9b7f3d56a0: Layer already exists 
f1b5933fe4b5: Layer already exists 
latest: digest: sha256:2773451b3cc1fdeba04a9cdb512d474a289fe73745ace1e6949e772a86a0926b size: 1159
WKMIN1307242:Downloads ritgirdh$ docker push gcr.io/charged-library-280615/report-generator-service:latest
The push refers to repository [gcr.io/charged-library-280615/report-generator-service]
035c61f5476b: Layer already exists 
ceaf9e1ebef5: Layer already exists 
9b9b7f3d56a0: Layer already exists 
f1b5933fe4b5: Layer already exists 
latest: digest: sha256:2773451b3cc1fdeba04a9cdb512d474a289fe73745ace1e6949e772a86a0926b size: 1159
```

## Google Cloud Run Set up

### Enable Cloud Run Service 
![enable cloud run api](images/enable-cloud-run.png)

### Understand Cloud Run - terraform resource   
```
resource "google_cloud_run_service" "report-generator-service" {
  name     = "report-generator-service"
  location = "us-east4"

  template {
    spec {
      containers {
        image = "gcr.io/charged-library-280615/report-generator-service"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
```

It will create cloud run service report-generator-service , running container will start serving 100% traffic. In case of updation or deployment, previous running 
instance will serve running threads and new up instance will start handling all 100% traffic. We could also manage traffic if require. 

### Understand Google Scheduler job - terraform resource 
````
resource "google_cloud_scheduler_job" "updater" {
  name             = "daily-report-generation-job"
  description      = "It will generate daily report"
  schedule         = "0 0 18 ? * * *"
  time_zone        = "GMT"

  http_target {
    http_method = "GET"
      uri = "${google_cloud_run_service.report-generator-service.status[0].url}/v1/weather/hello1"

    oidc_token {
      service_account_email = "terraform@charged-library-280615.iam.gserviceaccount.com"
    }
  }
}
````

#### Initialize 
```
$ terraform init
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

### Enable below api's 
![enable compute engine](images/enable-compute-engine.png)
![enable compute engine](images/compute-engine-1.png)
![enable compute engine](images/enable-iam-api.png)
![enable compute engine](images/iam-api.png)
![enable cloud scheduler](images/cloud-scheduler-1.png)
![enable cloud scheduler](images/cloud-scheduler-2.png)

#### Apply changes.
```        
$ terraform apply
data.google_compute_default_service_account.default: Refreshing state...
google_cloud_run_service.report-generator-service: Refreshing state... [id=locations/us-east4/namespaces/charged-library-280615/services/report-generator-service]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_cloud_run_service.report-generator-service will be created
  + resource "google_cloud_run_service" "report-generator-service" {
      + id       = (known after apply)
      + location = "us-east4"
      + name     = "report-generator-service"
      + project  = (known after apply)
      + status   = (known after apply)

      + metadata {
          + annotations      = (known after apply)
          + generation       = (known after apply)
          + labels           = (known after apply)
          + namespace        = (known after apply)
          + resource_version = (known after apply)
          + self_link        = (known after apply)
          + uid              = (known after apply)
        }

      + template {

          + spec {
              + serving_state = (known after apply)

              + containers {
                  + image = "gcr.io/charged-library-280615/report-generator-service"
                }
            }
        }

      + traffic {
          + latest_revision = true
          + percent         = 100
        }
    }

  # google_cloud_scheduler_job.updater will be created
  + resource "google_cloud_scheduler_job" "updater" {
      + description = "It will generate daily report"
      + id          = (known after apply)
      + name        = "daily-report-generation-job"
      + project     = (known after apply)
      + region      = (known after apply)
      + schedule    = "* 18 * * *"
      + time_zone   = "GMT"

      + http_target {
          + http_method = "GET"
          + uri         = "https://report-generator-service-zrjjlwqnjq-uk.a.run.app/v1/weather/hello1"

          + oidc_token {
              + service_account_email = "terraform@charged-library-280615.iam.gserviceaccount.com"
            }
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_cloud_run_service.report-generator-service: Creating...
google_cloud_run_service.report-generator-service: Still creating... [10s elapsed]
google_cloud_run_service.report-generator-service: Still creating... [20s elapsed]
google_cloud_run_service.report-generator-service: Still creating... [30s elapsed]
google_cloud_run_service.report-generator-service: Still creating... [40s elapsed]
google_cloud_run_service.report-generator-service: Creation complete after 49s [id=locations/us-east4/namespaces/charged-library-280615/services/report-generator-service]
google_cloud_scheduler_job.updater: Creating...
google_cloud_scheduler_job.updater: Creation complete after 6s [id=projects/charged-library-280615/locations/us-east4/jobs/daily-report-generation-job]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

url = https://report-generator-service-zrjjlwqnjq-uk.a.run.app
```

### Check Cloud run service and scheduler 
![cloud-run-created](images/cloud-run-created.png)
![scheduler-created](images/scheduler-created.png)

### Delete Cloud run service + Scheduler job 
```
terraform destroy
```


## How to invoke Cloud Run api via postman ?
We have configured Open ID Connect for securly accessing cloud run api via scheduler. But sometime we need to invoke cloud run api for debugging purpose 
for that you should have token. 

#### Activate Service account
```
$ gcloud auth activate-service-account --key-file=key.json
Activated service account credentials for: [service-account]
```
#### Print Token 
```
$ gcloud auth print-identity-token --audiences=https://test-bmgsrd6uza-uc.a.run.app
eyJhbGciOiJSUzI1NiIsImtpZCI6ImIxNm........
```

#### Invoke api with token
```
$ curl -ivk --location --request GET 'https://test-bmgsrd6uza-uc.a.run.app/v1/weather/hello1' \
--header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImIxNm.....'

*   Trying 216.239.36.53...
* TCP_NODELAY set
* Connected to test-bmgsrd6uza-uc.a.run.app (216.239.36.53) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-ECDSA-CHACHA20-POLY1305
* ALPN, server accepted to use h2
* Server certificate:
*  subject: C=US; ST=California; L=Mountain View; O=Google LLC; CN=*.a.run.app
*  start date: May 26 15:20:56 2020 GMT
*  expire date: Aug 18 15:20:56 2020 GMT
*  issuer: C=US; O=Google Trust Services; CN=GTS CA 1O1
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x7feac4808c00)
> GET /v1/weather/hello1 HTTP/2
> Host: test-bmgsrd6uza-uc.a.run.app
> User-Agent: curl/7.54.0
> Accept: */*
> Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImIxNm......
> 
* Connection state changed (MAX_CONCURRENT_STREAMS updated)!
< HTTP/2 200 
HTTP/2 200 
< content-type: text/plain;charset=UTF-8
content-type: text/plain;charset=UTF-8
< date: Tue, 16 Jun 2020 06:30:58 GMT
date: Tue, 16 Jun 2020 06:30:58 GMT
< server: Google Frontend
server: Google Frontend
< content-length: 8
content-length: 8
< alt-svc: h3-27=":443"; ma=2592000,h3-25=":443"; ma=2592000,h3-T050=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q049=":443"; ma=2592000,h3-Q048=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
alt-svc: h3-27=":443"; ma=2592000,h3-25=":443"; ma=2592000,h3-T050=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q049=":443"; ma=2592000,h3-Q048=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"

< 
* Connection #0 to host test-bmgsrd6uza-uc.a.run.app left intact
message1
```