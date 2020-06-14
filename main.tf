provider "google" {
  version = "3.5.0"
  credentials = file("loblaw-280320-9e0236ac2d5c.json")
  project = "loblaw-280320"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_cloud_run_service" "weather-service" {
  name     = "weather-service"
  location = "us-central1"

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

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "policy" {
  location    = google_cloud_run_service.weather-service.location
  project     = google_cloud_run_service.weather-service.project
  service     = google_cloud_run_service.weather-service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

//resource "google_cloud_scheduler_job" "job" {
//  name             = "test-job1"
//  description      = "test http job"
//  schedule         = "* */8 * * *"
//  time_zone        = "America/New_York"
//
//  retry_config {
//    retry_count = 1
//  }
//
//  http_target {
//    http_method = "GET"
//    uri         = "${google_cloud_run_service.default.status[0].url}/v1/weather/hello1"
//  }
//
//}
