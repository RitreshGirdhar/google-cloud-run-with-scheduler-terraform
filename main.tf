provider "google" {
  version = "3.5.0"
  credentials = file("api-project-808184727589-01c25b6570c9.json")
  project = "api-project-808184727589"
  region  = "us-central1"
  zone    = "us-central1-c"
}

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
