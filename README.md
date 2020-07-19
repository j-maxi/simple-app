# Design Pattern Demo application

Sample application to show how Design Pattern as Code works.

## Overview

This application is a simple Flask API and uses `kubernetes/base` and `gcp/api` Design Patterns, which run the app with the following GCP products.
* Google Kubernetes Engine
* Cloud Load Balancing with Network Endpoint Group (NEG)
* Cloud Monitoring UptimeCheck

`build/app.cue` is the application config to declare which Design Pattern to use.
The actual Design Patterns are placed in https://github.com/j-maxi/designpattern-as-code.
In this demo code, we load `build/app.cue` to resolve Design Patterns and generate a Tekton Pipeline configuration.
The Pipeline will take care of deploying this application including generating Kubernetes and GCP Manifest.

## Prerequisites

We expect the following preparations prior to run this demo.
* Create GKE cluster and install Tekton v0.13.2 or higher to the cluster.
  * We call this "Tekton cluster".
  * See [Tekton Installation Guide](https://github.com/tektoncd/pipeline/blob/master/docs/install.md).
* Create another GKE cluster to host the demo application.
  * We call this "App cluster".
  * Can be the same cluster created above.
* Reserve Google Cloud public IP address with a name "kubecon-demo-ip".
  * Should be global scope (not regional).
* Add a DNS record for the application's domain name to assign the above public IP.
* Create an empty Deployment-Manager deployment named "kubecon-demo". 
* Create k8s PersistentVolumeClaim to the Tekton cluster for buildkit.
* Create k8s Secret to the Tekton cluster for a service account.
* **Update `app/build.cue` to specify your GCP setup.**
  * Specify GCP project ID and region.
  * Specify the App cluster's name you have created.
  * Specify the domain name.

### Create an empty Deployment-Manager deployment

Use `tools/empty.yaml` to create an empty deployment. We use this deployment to configure GCP resource, UptimeCheckConfig.

```bash
gcloud deployment-manager deployments create kubecon-demo-app --config=tools/empty.yaml
```

### Create k8s PersistentVolumeClaim

Use `tools/cache.yaml` to create a PVC used by buildkit.
Standard storage class is used for the demo's simplicity.

```bash
kubectl -n kubecon-demo apply -f tools/cache.yaml
```

### Create k8s Secret

Install a Google Cloud Service Account to k8s Secret to control resources in App cluster and GCP resources where App cluster runs.
The secret name must be "serviceaccount" and the file name must be "serviceaccount" as well.

```bash
gcloud --project=${APP_CLUSTER_PROJECT_ID} iam service-accounts keys create key.json --iam-account=${SERVICE_ACCOUNT}
kubectl -n kubecon-demo create secret generic serviceaccount --file-file=serviceaccount=key.json
rm key.json
```

## Run a demo

Prepare Design Patterns.

```bash
git clone https://github.com/j-maxi/designpattern-as-code designpatterns
cd designpatterns
```

Generate Tekton Pipeline.

```bash
./generateTektonPipeline.sh > pipeline.yaml
kubectl -n kubecon-demo apply -f pipeline.yaml
```

Run the pipeline to deploy this app.

```bash
cat <<END | kubectl -n kubecon-demo create -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: deploy-
spec:
  pipelineRef:
    name: deploy-with-designpattern-api
END
```

`base/app-without-api.cue` is a sample application config to show installing only the `base` Design Pattern.

## Acknowledgement

This application and Design Patterns implementations are simplified for the demo purpose. For example, in production, we should have a better way to handle Secert. Or we may deploy Google Cloud ManagedCertificate to enable TLS.
Feel free to contact <a href="https://twitter.com/junmakishi" target="_blank">`@JunMakishi`</a> to discuss how to use these patterns in production.

## License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) for more information.
