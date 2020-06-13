# Terraform gcp scheduler cloudrun

This application will help you in creating gcp cloud run service via terraform. 

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

