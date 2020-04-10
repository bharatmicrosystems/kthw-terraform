// Configure the Google Cloud provider
provider "google" {
 credentials = file("credentials.json")
 project     = var.project
 region      = var.region
}
