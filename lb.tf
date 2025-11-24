resource "google_compute_global_address" "wiki" {
  name = local.cloudrun_name
}

resource "google_compute_backend_service" "wiki" {
  name                  = local.cloudrun_name
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"
  timeout_sec           = 30

  backend {
    group = google_compute_region_network_endpoint_group.wiki.id
  }

  cdn_policy {
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
    default_ttl      = 3600
    max_ttl          = 86400
    client_ttl       = 3600
    negative_caching = true
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "wiki" {
  name            = local.cloudrun_name
  default_service = google_compute_backend_service.wiki.id
}

resource "google_compute_managed_ssl_certificate" "wiki" {
  name = replace(var.domain, ".", "-")

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_ssl_policy" "wiki" {
  name            = local.cloudrun_name
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_target_https_proxy" "wiki" {
  name             = local.cloudrun_name
  url_map          = google_compute_url_map.wiki.id
  ssl_certificates = [google_compute_managed_ssl_certificate.wiki.id]
  ssl_policy       = google_compute_ssl_policy.wiki.id

  lifecycle {
    ignore_changes = [ssl_certificates]
  }
}

resource "google_compute_global_forwarding_rule" "wiki_https" {
  name                  = "${local.cloudrun_name}-https"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.wiki.id
  ip_address            = google_compute_global_address.wiki.id
}