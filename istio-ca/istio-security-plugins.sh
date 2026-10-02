CERT_MANAGER_VERSION=v1.11.0
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --create-namespace \
 --version ${CERT_MANAGER_VERSION} \
 --set installCRDs=true \
 --wait;

kubectl -n cert-manager rollout status deploy/cert-manager;
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector;
kubectl -n cert-manager rollout status deploy/cert-manager-webhook;

###########################PCA Plugin Installation ###########################

export PCA_NAMESPACE=cert-manager
export AWSPCA_ISSUER_TAG=v1.2.2

# Install AWS Private CA Issuer Plugin
# https://github.com/cert-manager/aws-privateca-issuer/#setup
helm repo add awspca https://cert-manager.github.io/aws-privateca-issuer
helm repo update
helm upgrade --install aws-pca-issuer awspca/aws-privateca-issuer \
 --namespace ${PCA_NAMESPACE} \
 --set image.tag=${AWSPCA_ISSUER_TAG} \
 --set serviceAccount.create=false \
 --set serviceAccount.name="aws-pca-issuer" \
 --wait;

# Verify deployment status
kubectl -n ${PCA_NAMESPACE} \
 rollout status deploy/aws-pca-issuer-aws-privateca-issuer;