output "service_account_emails" {
  value = google_service_account.accounts[*].email
}

output "service_account_ids" {
  value = google_service_account.accounts[*].id
}
