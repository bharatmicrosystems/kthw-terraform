kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.200.0.0/16"
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/kube-dns.yaml
