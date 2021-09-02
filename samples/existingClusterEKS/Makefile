terraform-init:
	. ./env.sh && cd resources/ && terraform init -backend-config="bucket=$${AWS_TERRAFORM_STATE_BUCKET}"

terraform-apply:
	. ./env.sh && cd resources/ && terraform apply && terraform output -json > output.json

eks-create-sa: terraform-apply
	export AWS_TODO_API_IAM_POLICY_ARN=$$(cat resources/output.json | jq -r '.todo_api_role_arn.value'); \
	. ./env.sh; \
	eksctl create iamserviceaccount \
		  --name todo-api-sa \
		  --namespace $${NAMESPACE} \
		  --cluster $${CLUSTER_NAME} \
		  --attach-policy-arn $${AWS_TODO_API_IAM_POLICY_ARN} \
		  --approve \
		  --override-existing-serviceaccounts

deploy-expressjs: eks-create-sa
	. ./env.sh && helm upgrade -i todo-api -n $${NAMESPACE} examples_expressjs/ -f examples_expressjs/values.yaml --create-namespace

update-expressjs:
	. ./env.sh && helm upgrade todo-api -n $${NAMESPACE} examples_expressjs/ -f examples_expressjs/values.yaml \
					--set rebugit.apiKey=$${REBUGIT_API_KEY}

deploy-rebugit:
	. ./env.sh && helm upgrade -i rebugit -n rebugit rebugit/rebugit -f rebugit-values.yaml --create-namespace \
				  --set postgresql.postgresqlPassword=$${POSTGRES_PASSWORD} \
				  --set postgresql.postgresqlUserPassword=$${POSTGRES_USER_PASSWORD} \
				  --set keycloak.auth.adminPassword=$${KEYCLOAK_ADMIN_PASSWORD} \
				  --set keycloak.auth.userName=$${KEYCLOAK_USER_NAME} \
				  --set keycloak.auth.userPassword=$${KEYCLOAK_USER_PASSWORD}