provider "google" {
  version = "3.5.0"
  credentials = file("charged-library-280615-9fa9b79158d5.json")
  project = "charged-library-280615"
  region  = "us-east4"
  zone    = "us-east4-c"
}

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

output "url" {
  value = "${google_cloud_run_service.report-generator-service.status[0].url}"
}

data "google_compute_default_service_account" "default" {
}


resource "google_cloud_scheduler_job" "updater" {
  name             = "daily-report-generation-job"
  description      = "It will generate daily report"
  schedule         = "* 18 * * *"
  time_zone        = "GMT"

  http_target {
    http_method = "GET"
      uri = "${google_cloud_run_service.report-generator-service.status[0].url}/v1/weather/hello1"

    oidc_token {
      service_account_email = "terraform@charged-library-280615.iam.gserviceaccount.com"
    }
  }
}