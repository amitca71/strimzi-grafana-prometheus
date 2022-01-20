#!/bin/bash

#minikube start --memory=6144
create ns kafka
config set-context --current --namespace=kafka
kubectl create clusterrolebinding strimzi-cluster-operator-namespaced --clusterrole=strimzi-cluster-operator-namespaced --serviceaccount kafka:strimzi-cluster-operator
kubectl create clusterrolebinding strimzi-cluster-operator-entity-operator-delegation --clusterrole=strimzi-entity-operator --serviceaccount kafka:strimzi-cluster-operator
kubectl create clusterrolebinding strimzi-cluster-operator-topic-operator-delegation --clusterrole=strimzi-topic-operator --serviceaccount kafka:strimzi-cluster-operator
kubectl -n kafka create -f ../install/cluster-operator
kubectl create -f kafka-metrics.yaml
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka 
kubectl create -f  kafka-connect-metrics.yaml
kubectl apply -f prometheus-operator-deployment.yaml
kubectl apply -f prometheus-additional.yaml
kubectl create secret generic additional-scrape-configs --from-file=./prometheus-additional.yaml -n kafka
kubectl apply -f strimzi-pod-monitor.yaml
kubectl apply -f prometheus-rules.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
kubectl port-forward prometheus-prometheus-0 9090:9090>/dev/null 2&>1 &
#kubectl wait kafka/grafana --for=condition=Ready --timeout=300s -n kafka 
sleep 5
grafana_pod=$(kubectl get pods |grep grafana| cut -f 1 -d ' ')
[ -z $grafana_pod ] && echo "grafana_pod not created" && exit 1
kubectl port-forward $grafana_pod 3000:3000>/dev/null 2&1 &
