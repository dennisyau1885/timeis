all: view_k8s_cluster

deploy: create_k8s_cluster create_k8s_ingress create_k8s_pv \
		load_image_to_k8s_cluster deploy_app \

destroy: delete_k8s_cluster

view_k8s_cluster:
	kind get clusters

create_k8s_cluster:
	kind create cluster --config kind/kind.yml

delete_k8s_cluster:
	kind delete cluster

load_image_to_k8s_cluster:
	kind load docker-image timeis:latest

create_k8s_ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx \
	--for=condition=ready pod \
	--selector=app.kubernetes.io/component=controller \
	--timeout=90s

create_k8s_pv:
	kubectl apply -f k8s/pv.yaml

deploy_app:
	kubectl apply -f k8s/deployment.yml

deploy_k8s_dashboard:
	helm install k8s-dash kubernetes-dashboard/kubernetes-dashboard
	#$(eval export POD_NAME=$$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=k8s-dash" -o jsonpath="{.items[0].metadata.name}"))
	# kubectl -n default port-forward ${POD_NAME} 8443:8443
	kubectl apply -f k8s/k8s-dashboard-ingres.yml
	kubectl apply -f k8s/create-service-account.yaml
	kubectl get secret $$(kubectl get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
