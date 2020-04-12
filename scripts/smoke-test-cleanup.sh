echo 'Cleanup'
kubectl delete secret kubernetes-the-hard-way
kubectl delete svc nginx
kubectl delete deployment nginx
kubectl delete deployment busybox
