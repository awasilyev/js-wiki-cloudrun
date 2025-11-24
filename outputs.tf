output "public_ip_address" {
  value = google_compute_global_address.wiki.address
}