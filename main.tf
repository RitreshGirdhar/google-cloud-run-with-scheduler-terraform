provider "google" {
  version = "3.5.0"
  credentials = file("api-project-808184727589-01c25b6570c9.json")
  project = "api-project-808184727589"
  region  = "us-central1"
  zone    = "us-central1-c"
}

//data "google_container_registry_repository" "weather-service" {
//}
//
//output "gcr_location" {
//  value = data.google_container_registry_repository.weather-service.repository_url
//}

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

output "url" {
  value = "${google_cloud_run_service.default.status[0].url}"
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
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_scheduler_job" "job" {
  name             = "test-job"
  description      = "test http job"
  schedule         = "* */8 * * *"
  time_zone        = "America/New_York"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = "${google_cloud_run_service.default.status[0].url}/v1/weather/hello1"
  }

}
