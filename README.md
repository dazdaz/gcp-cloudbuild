To use this builder, your builder service account will need IAM permissions sufficient for the operations you want to perform. For typical read-only usage, the "Kubernetes Engine Viewer" role is sufficient. To deploy container images on a GKE cluster, the "Kubernetes Engine Developer" role is sufficient. Check the GKE IAM page for details.

Running the following command will give Cloud Build Service Account container.developer role access to your Container Engine clusters:

### Prep work
```
gcloud config set project <my-project>

gcloud services enable containerregistry.googleapis.com

gcloud services enable cloudbuild.googleapis.com

gcloud container clusters get-credentials --zone=europe-west4-a <cluster>

PROJECT="$(gcloud projects describe \
    $(gcloud config get-value core/project -q) --format='get(projectNumber)')"

gcloud projects add-iam-policy-binding $PROJECT \
    --member=serviceAccount:$PROJECT@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer
```

### Example 1 - Manually submit a Cloud Build job
```
# Need to deploy pod once
kubectl apply -f deployment.yaml
gcloud builds submit --config=cloudbuild.yaml
kubectl logs -lrun=exapp -f
```

### Example 2 - Setup CICD - Create a repo, and setup a Cloud Build trigger
```
ssh-keygen -t rsa -b 4096 -C "source repo build <email>" -f ~/.ssh/myrepokey -P ''
cat ~/.ssh/myrepokey.pub
```
### Upload key to
https://source.cloud.google.com/user/ssh_keys

### Setup Cloud Build
 * Create GCP source repo
 * Configure authentication over SSH 
 * push config files+code to the repo
```
gcloud source repos create mycode-repo
gcloud source repos describe mycode-repo
git config user.email <youraccount>
cat > ~/.ssh/config <<EOF
Host source.developers.google.com
    HostName source.developers.google.com
    User <youraccount>
    IdentityFile ~/.ssh/sourcerepobuild
EOF
git remote add origin ssh://source.developers.google.com:2022/p/<project>/r/<yourrepo>
git add main.go Dockerfile cloudbuild.yaml
git commit "files"
git push origin master
```

### Trigger a manual Cloud Build run
```
# Create the cloud build trigger
gcloud beta builds triggers import --source=trigger.yaml --verbosity debug
gcloud beta builds triggers list
```

### Trigger an automated Cloud Build run
 * Edit some code
 * Commit those changes back to the repo
```
vim main.go
git add main.go
git commit main.go -m "update 1"
git push origin master
watch -t -n2 kubectl logs -lrun=exapp
kubectl get events --sort-by='{.lastTimestamp}' --namespace=default --watch
```

### Goto the following services in the portal
 * Cloud Build History
 * Container Registry
 * Cloud Source Repositories
