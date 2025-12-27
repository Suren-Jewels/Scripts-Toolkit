resource "google_service_account" "accounts" {
  count        = length(var.service_accounts)
  account_id   = var.service_accounts[count.index].account_id
  display_name = var.service_accounts[count.index].display_name
  project      = var.project_id
}

resource "google_project_iam_member" "bindings" {
  count   = length(var.bindings)
  project = var.project_id
  role    = var.bindings[count.index].role
  member  = "serviceAccount:${google_service_account.accounts[var.bindings[count.index].sa_index].email}"
}
