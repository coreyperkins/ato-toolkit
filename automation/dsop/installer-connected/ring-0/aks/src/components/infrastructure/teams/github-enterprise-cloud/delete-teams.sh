#!/usr/bin/env bash
set -euxo pipefail
# This script creates / updates teams in github. The $_teams param should be *all* teams needed in the system, not just new ones needed.

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../../../runtime/bootstrap/lib/tools.sh"

_storage_account_name="$1"
_container_name="$2"
_container_rg="$3"
_access_token="$4"
_subscription_id="$5"
_org="$6"
_prefix="$7"
_applications="$8"
_timestamp="$(date "+%Y:%m:%d-%H:%M")"


pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 2

terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

terraform plan \
    -destroy \
    -out "${_timestamp}.tfplan" \
    -var "access_token=$_access_token" \
    -var "org=$_org" \
    -var "access_token=$_access_token" \
    -var "subscription_id=$_subscription_id" \
    -var "prefix=$_prefix" \
    -var "applications=$_applications"

terraform apply "${_timestamp}.tfplan"
rm "${_timestamp}.tfplan"
rm -rf .terraform
popd || exit 2