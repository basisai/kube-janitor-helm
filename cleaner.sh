#!/bin/bash

TIMESTAMP=$(date +%Y%M%d_%H%M%S)
TTL_SECONDS=1814400
K8S_CONTEXT=$(kubectl config current-context)

read -p "Operating in K8s context ${K8S_CONTEXT}. Are you sure? [y/N] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# service
eval 'kubectl get ingress --show-kind --ignore-not-found -l bdrk.ai/creator --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > service_${TIMESTAMP}.json
cat service_${TIMESTAMP}.json
# kubectl delete -f service_${TIMESTAMP}.json

# ingress
eval 'kubectl get ingress --show-kind --ignore-not-found -l bdrk.ai/creator --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > ingress_${TIMESTAMP}.json
cat ingress_${TIMESTAMP}.json
# kubectl delete -f ingress_${TIMESTAMP}.json

# deployment
eval 'kubectl get deployment --show-kind --ignore-not-found -l bdrk.ai/creator --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > deployment_${TIMESTAMP}.json
cat deployment_${TIMESTAMP}.json
# kubectl delete -f deployment_${TIMESTAMP}.json

# job
eval 'kubectl get job --show-kind --ignore-not-found -l bdrk.ai/creator --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | select(.status.failed or .status.succeeded) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata, "status":.status}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > jobs_${TIMESTAMP}.json
cat jobs_${TIMESTAMP}.json
# kubectl delete -f jobs_${TIMESTAMP}.json

# secret
eval 'kubectl get secret --show-kind --ignore-not-found -l bdrk.ai/creator --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > secret_${TIMESTAMP}.json
cat secret_${TIMESTAMP}.json
# kubectl delete -f secret_${TIMESTAMP}.json

# configmap (helm release metadata)
eval 'kubectl get configmap --show-kind --ignore-not-found -l OWNER=TILLER --namespace='{deployment,training}' --sort-by=.metadata.creationTimestamp -o json;' \
  | jq -r --arg ttl_seconds ${TTL_SECONDS} '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - ($ttl_seconds | tonumber))) | {"apiVersion":.apiVersion, "kind":.kind, "metadata":.metadata}' \
  | jq -s '{"apiVersion":"v1", "kind":"List", "items":.}' > configmap_${TIMESTAMP}.json
cat configmap_${TIMESTAMP}.json
# kubectl delete -f configmap_${TIMESTAMP}.json

# horizontalpodautoscaler
# cronjob
