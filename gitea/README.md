kubectl patch service ingress-nginx -n ingress-nginx -p "$\(cat patches/ingress-nginx-service.yaml\)"
kubectl patch configmap tcp-services -n ingress-nginx -p "$\(cat patches/ingress-nginx.yaml\)"
