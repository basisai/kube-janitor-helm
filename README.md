# Bedrock K8s resource cleaner

Deletes:
- Service
- Ingress
- Deployment
- Job
- Secret
- ConfigMap
- HPA
- CronJob

Found in namespaces:
- deployment
- training

If more than 21 days.


## Using bash script

### Run
```bash
./cleaner.sh
```

## Using Kube-janitor

### Preview
```bash
python3 -m kube_janitor --dry-run --once --exclude-namespaces=kube-system,core --rules=./janitor-rules.yaml
```

### Run
```bash
python3 -m kube_janitor --once --exclude-namespaces=kube-system,core --rules=./janitor-rules.yaml
```
