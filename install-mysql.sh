#!/bin/bash

password=$1

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

generate_secure_password() {
  if ! command -v openssl &> /dev/null; then
    echo "Error: OpenSSL not found. Secure password generation unavailable."
    return 1
  fi
  length=20
  password=$(openssl rand -base64 $length | tr -dc 'A-Za-z0-9')
}

execute() {
  command="$@"
  echo "Executing command: '$command'"
  $command
  if [[ $? -ne 0 ]]; then
    echo "Error: '$command' failed with exit code: $?."
  else
    echo "Successfully executed command: '$command'"
  fi
}

echo $password
if [ ! -n "$password" ]; then
  generate_secure_password
fi
echo "Your password: $password"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: kubernetes.io/basic-auth
stringData:
  password: $password
EOF
execute "kubectl apply -f https://raw.githubusercontent.com/WildePizza/kubernetes-apps/HEAD/mysql.yaml"
execute "kubectl apply -f https://raw.githubusercontent.com/WildePizza/kubernetes-apps/HEAD/phpmyadmin.yaml"
