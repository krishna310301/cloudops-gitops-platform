#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-2}}"

required_commands=(aws python3)

for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
done

identity_json="$(aws sts get-caller-identity --output json)"

account_id="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["Account"])' <<<"$identity_json")"
caller_arn="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["Arn"])' <<<"$identity_json")"
policy_source_arn="$caller_arn"

if [[ "$caller_arn" == arn:aws:sts::*:assumed-role/* ]]; then
  role_name="${caller_arn#*:assumed-role/}"
  role_name="${role_name%%/*}"
  policy_source_arn="arn:aws:iam::${account_id}:role/${role_name}"
fi

actions=(
  "ec2:CreateVpc"
  "ec2:CreateSubnet"
  "ec2:CreateInternetGateway"
  "ec2:AttachInternetGateway"
  "ec2:CreateRouteTable"
  "ec2:CreateRoute"
  "ec2:AssociateRouteTable"
  "ec2:CreateSecurityGroup"
  "ec2:AuthorizeSecurityGroupEgress"
  "ec2:CreateTags"
  "eks:CreateCluster"
  "eks:CreateNodegroup"
  "eks:DescribeCluster"
  "iam:CreateRole"
  "iam:AttachRolePolicy"
  "iam:PassRole"
  "iam:CreatePolicy"
  "ecr:CreateRepository"
  "ecr:PutLifecyclePolicy"
  "ecr:GetAuthorizationToken"
  "ecr:BatchCheckLayerAvailability"
  "ecr:InitiateLayerUpload"
  "ecr:UploadLayerPart"
  "ecr:CompleteLayerUpload"
  "ecr:PutImage"
)

tmp_output="$(mktemp)"
tmp_error="$(mktemp)"
cleanup() {
  rm -f "$tmp_output" "$tmp_error"
}
trap cleanup EXIT

echo "AWS account: $account_id"
echo "Caller ARN: $caller_arn"
echo "Policy source ARN: $policy_source_arn"
echo "Region: $REGION"
echo
echo "Checking whether this identity can create the AWS resources used by terraform/envs/dev..."

if ! aws iam simulate-principal-policy \
  --policy-source-arn "$policy_source_arn" \
  --action-names "${actions[@]}" \
  --resource-arns "*" \
  --region "$REGION" \
  --output json >"$tmp_output" 2>"$tmp_error"; then
  echo "Could not run iam:SimulatePrincipalPolicy for this identity." >&2
  echo "The AWS identity may also need iam:SimulatePrincipalPolicy, or you can review the required actions below manually." >&2
  echo >&2
  cat "$tmp_error" >&2
  echo >&2
  printf 'Required apply/push actions:\n' >&2
  printf '  - %s\n' "${actions[@]}" >&2
  exit 2
fi

python3 - "$tmp_output" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    payload = json.load(handle)

denied = []
for result in payload.get("EvaluationResults", []):
    decision = result.get("EvalDecision")
    if decision != "allowed":
        denied.append((result.get("EvalActionName"), decision))

if denied:
    print("Missing or not-allowed AWS permissions:")
    for action, decision in denied:
        print(f"  - {action}: {decision}")
    sys.exit(2)

print("AWS permission preflight passed for the apply/push actions checked here.")
PY
