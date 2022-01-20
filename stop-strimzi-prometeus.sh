#!/bin/bash

kubectl apply -f prometheus-rules.yaml
kubectl apply -f prometheus.yaml
kubectl delete -f grafana.yaml
kubectl apply -f strimzi-pod-monitor.yaml
kubectl delete -f prometheus-additional.yaml
kubectl delete -f prometheus-additional.yaml
kubectl delete -f kafka-metrics.yaml
kubectl delete -f  kafka-connect-metrics.yaml
kubectl delete -f prometheus-operator-deployment.yaml
kubectl delete secret generic additional-scrape-configs -n kafka
kubectl -n kafka delete -f ../install/cluster-operator
kill -9 $(ps -ef  | grep port-forward  | grep grafana |  grep -v grep | awk {'print$2'})
kill -9 $(ps -ef  | grep port-forward  | grep prometheus-prometheus-0 | grep -v grep | awk {'print$2'})


