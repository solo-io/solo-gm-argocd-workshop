# install argocd
kubectl create namespace argocd --context mgmt
kubectl apply -n argocd --context mgmt -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl rollout status deploy/argocd-server -n argocd --context mgmt
kubectl rollout status deploy/argocd-applicationset-controller -n argocd --context mgmt

#set argo svc type=lb
kubectl patch svc argocd-server -n argocd --context mgmt -p '{"spec": {"type": "LoadBalancer"}}'

# set admin password: solo.io
kubectl --context mgmt -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$79yaoOg9dL5MO8pn8hGqtO4xQDejSEVNWAGQR268JHLdrCw6UCYmy",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# register workload clusters
sleep 20
argocd login 192.168.64.41 --insecure --username admin --password solo.io
sleep 5
argocd cluster add cluster1 -y
sleep 5
argocd cluster add cluster2 -y
