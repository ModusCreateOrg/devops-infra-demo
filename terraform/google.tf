provider "google" {
  version = "~> 1.20"
}

resource "google_storage_bucket" "website-storage" {
  name     = "${var.google_project}-website-storage"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "50x.html"
  }
}

resource "google_storage_bucket_object" "overlay" {
  name   = "images/overlay.png"
  source = "../application/images/overlay.png"
  bucket = "${google_storage_bucket.website-storage.name}"
}

resource "google_storage_bucket_object" "background" {
  name   = "images/bg.jpg"
  source = "../application/images/bg.jpg"
  bucket = "${google_storage_bucket.website-storage.name}"
}

resource "google_storage_object_acl" "overlay-acl" {
  bucket = "${google_storage_bucket.website-storage.name}"
  object = "${google_storage_bucket_object.overlay.name}"

  predefined_acl = "publicread"
}

resource "google_storage_object_acl" "background-acl" {
  bucket = "${google_storage_bucket.website-storage.name}"
  object = "${google_storage_bucket_object.background.name}"

  predefined_acl = "publicread"
}

output "google-bucket-link" {
  value = "${google_storage_bucket.website-storage.self_link}"
}
