provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_project" "credation_test" {
  name       = "${var.project}"
  project_id = "${var.project}-id"
  org_id     = "${var.org_id}"
}

# create service account needed

# enable needed apis

