#!/usr/bin/env bash

set -e

script_dir=$(dirname -- "$0")
project_dir=$script_dir/../../
chromia_yml=$project_dir/chromia.yml
chromia_yml_modified=$project_dir/chromia.yml.orig
secret=$script_dir/devnet2_secret
node_url=$(grep api.url "$secret" | sed 's/^api.url[ =]*//g')

# Blockchains to verify
# <chromia.yml name>:<real name in cluster>
blockchains_to_verify=(
  "mainnet:directory_chain"
  "system_anchoring:system_anchoring"
  "cluster_anchoring:cluster_anchoring_system"
  "economy_chain_test:economy_chain"
)

directory_chain_brid=$(curl -s "$node_url/brid/iid_0")
echo "Directory chain brid: $directory_chain_brid"

blockchains=$(curl -s "${node_url}/query/${directory_chain_brid}?type=get_blockchain_info_list&include_inactive=false")

verification_failed=0
for bc in "${blockchains_to_verify[@]}" ; do
    bc_settings_name="${bc%%:*}"
    bc_node_name="${bc##*:}"

    cp "$chromia_yml" "$chromia_yml_modified"

    bcrid=$(echo "$blockchains" | jq -r ".[] | select(.name == \"$bc_node_name\").rid" )
    echo
    echo "Verifying $bc_settings_name / $bc_node_name with bcrid $bcrid"

    cat << EOF >> "$chromia_yml_modified"

deployments:
  devnet2:
    brid: x"$directory_chain_brid"
    url:
      - ${node_url}
    container: system
    chains:
      $bc_settings_name: x"$bcrid"
EOF

    chr deployment update -s "$chromia_yml_modified" -d devnet2 -bc "$bc_settings_name" --secret "$secret" --verify-only || verification_failed=1

done
rm "$chromia_yml_modified"

echo
echo -n "Verification "
if [ $verification_failed == "0" ]; then
  echo "PASSED"
else
  echo "FAILED"
  exit 1
fi

