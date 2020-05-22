#!/bin/bash

command="cd console && source ./contrib/oc-environment.sh && ./bin/bridge"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage: deploy.sh <name> [custom shell commands (typically git)]"
    echo
    echo "Everything this script creats will be called <name>. It creates a project called <name> inside it creates the pod called <name> etc"
    echo "If the custom shell command is supplied, it will be executed just before building the project. This commands will typically be git commands to download a specific patch or to switch to a specific repo."
    echo
    echo "Examples:"
    echo "Run the version of the console as is in the container in a project called myproject: ./deploy.sh myproject"
    echo "Checkout the 4.4 version of it, build and run it in a project caled myproject: ./deploy.sh myproject \"git checkout -b origin/release-4.4\""
    echo "Checkout a specific github patch and run in in a project called myproject: ./deploy.sh myproject \"git fetch origin && git reset --hard origin/master && git fetch origin pull/5531/head:B && git checkout B\""
    echo "Please note that the content of the command is just a shell command. You can prepare the workspace using any shell commands you need."
    exit
  else if [ $# -eq 1 ]
    then
      project=$1
      command="cd console && source ./contrib/oc-environment.sh && ./bin/bridge"
  else if [ $# -eq 2 ]
    then
      project=$1
      command="cd console && "$2" && ./build.sh && source ./contrib/oc-environment.sh && ./bin/bridge"
    fi
    fi
fi

echo "creating project"
oc new-project $project

echo "creatin service account"
oc create sa $project

echo "giving service account admin permissions"
oc create clusterrolebinding $project --clusterrole=cluster-admin --serviceaccount=$project:$project -n ocp-devel-preview

echo "deploying the main pod and service"

cat <<EOF | oc create -f -
apiVersion: v1
kind: Pod
metadata:
  name: "$project"
  namespace: $project
  labels:
    app: $project
spec:
  serviceAccountName: $project
  containers:
  - name: okd-devel-prev
    image: jelkosz/okd-devel-prev:v1 
    command: ["/bin/sh","-c"]
    args: ["$command"]
    ports:
    - containerPort: 9000
---
kind: Service
apiVersion: v1
metadata:
  name: $project
  namespace: $project
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9000
  selector:
    app: $project
  type: ClusterIP
  sessionAffinity: None
EOF

echo "exposing route"
oc expose svc/$project

echo
echo "Seems its done. Once the bridge process inside of the container starts, you should be able to access the console on the following address:"
echo "http://$(oc get routes -o=custom-columns=HOSTNAME:.spec.host | tail -1)"
echo
echo "Alternatively, you can expose it using port forwarding:"
echo "oc port-forward pods/$project 8080:9000"
echo "and access it on http://localhost:8080"
