# Required variables
# ==================
#
# Set these variables locally (e.g. in *.auto.tfvars, environment variables,
# or inject at runtime) or in Terraform Cloud if using remote execution.
# Cloud workspace variables override local variables.
# Any of the variables in variables.tf with defaults can also be overridden here.
#

do_token="Your DigitalOcean API personal access token"
do_spaces_access_key = "Your DigitalOcean Spaces API access key ID"
do_spaces_secret_key = "Your DigitalOcean Spaces API access key secret"
github_token="Your GitHub.com personal access token, which has access to the repository"
github_owner="The GitHub.com username or organization, which owns the repository"
