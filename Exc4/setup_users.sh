#!/bin/zsh

# Предполагается, что обычными пользователями управляет внешняя, независимая служба.
# В ее роли может выступать администратор, распределяющий закрытые ключи, хранилище пользователей вроде Keystone или Google Accounts, или даже файл со списком имен пользователей и паролей.
# В связи с этим в Kubernetes нет объектов, представляющих обычных пользователей. Обычных пользователей нельзя добавить в кластер через вызов API (с) Документация Kubernetes

# Создаем сертификаты пользователей (По одному пользователю на роль)

# Создаем ключ
openssl genrsa -out security.key 2048
# Создаем CSR
openssl req -new -key security.key -out security.csr -subj "/CN=security"
# Создаем сертификат на 365 дней
openssl x509 -req -in security.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out security.crt -days 365

# Повторяем для остальных пользователей
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -out admin.csr -subj "/CN=admin"
openssl x509 -req -in admin.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out admin.crt -days 365

openssl genrsa -out devops.key 2048
openssl req -new -key devops.key -out devops.csr -subj "/CN=devops"
openssl x509 -req -in devops.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out devops.crt -days 365

openssl genrsa -out developer.key 2048
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"
openssl x509 -req -in developer.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out developer.crt -days 365

# Создаем пользователей в Kubernetes с созданными сертификатами
kubectl config set-credentials security --client-certificate=./security.crt --client-key=./security.key
kubectl config set-credentials admin --client-certificate=./admin.crt --client-key=./admin.key
kubectl config set-credentials devops --client-certificate=./devops.crt --client-key=./devops.key
kubectl config set-credentials developer --client-certificate=./developer.crt --client-key=./developer.key

# Применение ролей и связывание добавил сюда же, нет смысла выносить одну команду в отдельный скрипт
kubectl apply -f roles.yaml
kubectl apply -f role_bindings.yaml
