# Configuring Gloo Mesh with ArgoCD

## Introduction
The presentation slides for this repo is available in the repo doc, Gloo Mesh Management with GitOps.pdf. It should be used inconjunction with the [Solo Gloo Mesh Workshop repo](https://github.com/solo-io/workshops/tree/master/gloo-mesh-all), which provides more context for policies and configurations applied.  
Also view the recording of the workshop, which is provided separately.

## Pre requisites
* 3 x Kubernetes clusters v1.21 and set the k8s cluster contextes:
```
export MGMT=mgmt
export CLUSTER1=cluster1
export CLUSTER2=cluster2
```
* Gloo Mesh v1.2.13 (see workshop repo)
* Istio v1.11 (see workshop repo)
* BookInfo demo application (see workshop repo)
* ArgoCD v2.3.3 cli, e.g. `brew install argocd`

* Fork and Clone the repo and cd to the repo folder, then run `bash install-argocd.sh` to install ArgoCd to the kubernetes clusters.  

* Update Kubernetes RBAC to allow ArgoCD service account:  
`kubectl apply -f update-gm-rbac.yaml`
* Export Gloo Mesh gateway environment variables:
```
export ENDPOINT_HTTP_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):80
export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${CLUSTER1} -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):443
export HOST_GW_CLUSTER1=$(echo ${ENDPOINT_HTTP_GW_CLUSTER1} | cut -d: -f1)
```

## Add ArgoCD Apps for each kubernetes cluster
Add a policy `ArgoCD App` for each of the kubernetes clusters, i.e. `mgmt` > policies/mgmt, `cluster1` > policies/cluster1 and `cluster2` > policies/cluster2.  

## Deploy Gloo Mesh Policies with ArgoCD
### Enable Zero Trust
#### Enbale Istio TLS
Remove the comment `#` from `#-  PeerAuthentication-IstioTLS.yaml`
```
vi policies/cluster1/kustomization.yaml
vi policies/cluster2/kustomization.yaml
git add --all && git commit -m "update $(date)" && git push origin main
```
Refresh and Sync the cluster1 and cluster2 Apps in ArgoCD UI.  

#### Established a shared root Trust with Gloo Mesh
Remove the comment from `#-  VirtualMesh.yaml`
```
vi policies/mgmt/kustomization.yaml
git add --all && git commit -m "update $(date)" && git push origin main
```
Refresh and Sync the management App in ArgoCD UI.  
#### Enable Gloo Mesh zero trust
Remove comment from `#globalAccessPolicy: ENABLED`
```
vi policies/mgmt/VirtualMesh.yaml
git add --all && git commit -m "update $(date)" && git push origin main
```
Refresh and Sync the management App in ArgoCD UI.  
#### Authorise services to communicate with each other
Remove comments from these lines:
* `#-  AccessPolicy-productpage.yaml `
* `#-  AccessPolicy-product-reviews.yaml`
* `#-  AccessPolicy-reviews-ratings.yaml`

```
vi policies/mgmt/kustomization.yaml
git add --all && git commit -m "update $(date)" && git push origin main
```
Refresh and Sync the management App in ArgoCD UI.  
### Apply Gloo Mesh traffic shift policy
Shift 75% traffic from cluster1 'reviews' to cluster2 'reviews'.  
Remove comment from `#-  TrafficPolicy-v3-75.yaml`
```
vi policies/mgmt/kustomization.yaml
git add --all && git commit -m "update $(date)" && git push origin main
```
Refresh and Sync the management App in ArgoCD UI. 
You will notice that you need to update your zero trust authorisation, to allow the new service to service communication.  
Remove comments from the Gloo Mesh AccessPolicy.
```
vi policies/mgmt/AccessPolicy-reviews-ratings.yaml
```
Refresh and Sync the management App in ArgoCD UI. 
## Conclusion
We can see that Gloo Mesh can be completely management via GitOps practises. All Gloo Mesh policies and configuration are kubernetes CRDs and CRs, which can be declared via yaml manifest files.