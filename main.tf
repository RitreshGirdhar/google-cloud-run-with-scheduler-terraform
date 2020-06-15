provider "google" {
  version = "3.5.0"
  credentials = file("loblaw-280320-9e0236ac2d5c.json")
  project = "loblaw-280320"
  region  = "us-east4"
  zone    = "us-east4-c"
}

resource "google_cloud_run_service" "weather-service" {
  name     = "weather-service"
  location = "us-east4"

  template {
    spec {
      containers {
        image = "gcr.io/loblaw-280320/ms1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "url" {
  value = "${google_cloud_run_service.weather-service.status[0].url}"
}

//data "google_iam_policy" "noauth" {
//  binding {
//    role = "roles/run.invoker"
//    members = [
//      "allUsers",
//    ]
//  }
//}
//
//resource "google_cloud_run_service_iam_policy" "policy" {
//  location    = google_cloud_run_service.weather-service.location
//  project     = google_cloud_run_service.weather-service.project
//  service     = google_cloud_run_service.weather-service.name
//  policy_data = data.google_iam_policy.noauth.policy_data
//}

data "google_compute_default_service_account" "default" {
}


resource "google_cloud_scheduler_job" "updater" {
  name             = "test-updater"
  description      = "test-updater"
  schedule         = "*/1 * * * *"
  time_zone        = "GMT"

  http_target {
    http_method = "GET"
      uri = "${google_cloud_run_service.weather-service.status[0].url}/v1/weather/hello1"

    oidc_token {
      service_account_email = "terraform@loblaw-280320.iam.gserviceaccount.com"
    }
  }
}
