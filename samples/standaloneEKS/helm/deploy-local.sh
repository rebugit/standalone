# This script is for testing only
export project_root="$HOME"/Development/Rebugit/rbi-standalone
export project_dir=samples/standaloneEKS/helm

echo "Creating Keycloak chart... ========================="
(cd "$project_root"/authentication/keycloak/helm/keycloak && helm package . &&  mv keycloak-3.1.1.tgz "$project_root"/helm/charts/keycloak-3.1.1.tgz) &&
echo "Creating Rebugit chart... ========================="
(cd "$project_root"/helm && helm dependency update; helm package . && mv rebugit-0.1.0.tgz "$project_root"/"$project_dir"/charts/rebugit-0.1.0.tgz ) &&
echo "Installing standaloneEKS chart... ========================="
(cd "$project_root"/"$project_dir" && helm dependency update; helm upgrade -i -n rebugit rebugit . -f values.yaml)
