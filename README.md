# ares-javascript-app-terraform

# How to deploy

# Download latest stable kubectl (Linux x86_64)
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  
chmod +x kubectl  
sudo mv kubectl /usr/local/bin/  

curl -Lo ./kind "https://kind.sigs.k8s.io/dl/$(curl -s https://kind.sigs.k8s.io/dl/latest)/kind-linux-amd64"  
chmod +x ./kind  
sudo mv kind /usr/local/bin/  

brew install docker-desktop  

docker ps  
kind --version  
kubectl version --client  
```

```
terraform init  
terraform plan  
terraform apply  
```
```
terraform output -raw kubeconfig > kubeconfig-kind  
```
# Backup existing config (if any)
```
mkdir -p ~/.kube  
[ -f ~/.kube/config ] && cp ~/.kube/config ~/.kube/config.bak  
```
# Merge: simplest is just to use KUBECONFIG env var when working with this cluster:
```
export KUBECONFIG=$PWD/kubeconfig-kind  
```
# Test
```
kubectl get nodes  
kubectl get pods -A  
```


# Or let kind create/configure context automatically
The provider will usually let kind manage $HOME/.kube/config, but if not, you can always do:  
```
kind get clusters  
kind get kubeconfig --name dev-cluster > kubeconfig-kind  
export KUBECONFIG=$PWD/kubeconfig-kind  
kubectl get nodes  
```

When you’re done:  
```
terraform destroy  
```

# Worklfow

GitHub → GitHub Actions → Build Docker image → Push to GHCR → 
ArgoCD watches Helm chart → Deploys to your kind cluster


# Prepare your Kubernetes cluster (kind)
You must install ArgoCD into your local kind cluster:
```
kubectl create namespace argocd  
kubectl apply -n argocd \  
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml  
```

Expose ArgoCD UI:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443  
```

check https://localhost:8080  

Get the admin password:
```
kubectl -n argocd get secret argocd-initial-admin-secret \  
  -o jsonpath="{.data.password}" | base64 -d; echo  
```
# Create ArgoCD Application for dev namespace
```
kubectl apply -f argocd-ares-dev.yaml  
```

ArgoCD will:
- Create namespace dev (thanks to CreateNamespace=true)
- Render your Helm chart
- Deploy MySQL + Secret + app + Services
- Keep them in sync with your Git repo

Check the deployment
```
kubectl get pods -n dev  
kubectl get svc -n dev  
```

You should see:
- mysql-… pod
- ares-app-… pod
- mysql service
- ares-app service

To access the app on your Mac (kind):
```
kubectl port-forward -n dev svc/ares-app 3000:3000  
```

check http://localhost:3000  
```
kubectl logs -n dev mysql-5dd49d94b8-927nx  
kubectl describe pod -n dev mysql-5dd49d94b8-927nx  
kubectl get pods -n dev  
kubectl logs -n dev deploy/mysql  
kubectl get pvc -n dev  
kubectl exec -n dev deploy/mysql -- env | grep MYSQL  
kubectl exec -n dev deploy/ares-app -- env | egrep 'DB_|APP_PORT'  
kubectl config current-context  
kubectl apply -f dev-app-ingress.yaml  
kubectl get ingress -n dev  
kubectl get ingress -n argocd  
```

Access:
App: http://app.localtest.me:port  
ArgoCD: http://argocd.localtest.me:port  

```
kubectl get ns | grep ingress  
```
You should see:
ingress-nginx   Active   ...
And the controller pod is here:
```
kubectl get pods -n ingress-nginx  
```
Expected output:
ingress-nginx-controller-xxxxx   1/1   Running


