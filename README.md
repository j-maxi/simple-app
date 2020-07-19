# Simple Application for Design Pattern Demo
Simple Flask App

## How to deploy this app

Prepare design pattern codes

```bash
git clone https://github.com/j-maxi/designpattern-as-code designpatterns
cd designpatterns
git checkout ${branchToUse}
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
    name: deploy-with-designpattern
END
```
