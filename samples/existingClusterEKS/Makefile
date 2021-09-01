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

deploy: eks-create-sa
	. ./env.sh && helm upgrade -i todo-api -n $${NAMESPACE} examples_expressjs/ -f examples_expressjs/values.yaml --create-namespace