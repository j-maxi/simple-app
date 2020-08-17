import (
	"github.com/j-maxi/designpattern-as-code/base:resource"
	"github.com/j-maxi/designpattern-as-code/kubernetes:base"
)

// a sample application config which only uses "base" Design Pattern

// global parameters
globalParams: {
	appName:    "kubecon-demo-app"
	repository: "https://github.com/j-maxi/simple-app"
	revision:   string @tag("revision")
	designpattern: {
		repository: "https://github.com/j-maxi/designpattern-as-code"
		revision:   string @tag("designpatternRevision")
	}
	gcp: {
		projectID: "REPLACE-with-your-gcp-project-id"
		region:    "REPLACE-with-your-region-preference"
	}
}

// Design Patterns to apply
patterns: [
	base.DesignPattern & {
		parameters: {
			globals:     globalParams
			namespace:   "kubecon-demo"
			image:       "gcr.io/\(globalParams.gcp.projectID)/kubecon-demo"
			clusterName: "REPLACE-with-your-app-cluster-name"
		}
	},
]

// create declarative Workflow and Manifest configurations

results: (resource.Composite & {input: patterns}).output

tektonPipeline: (resource.GenTektonPipeline & {input: results}).output

kubernetesManifests: (resource.GenKubernetesManifests & {input: results}).output

gcpManifests: (resource.GenGCPManifests & {input: results}).output

// NOTE: We have moved the Design Pattern composite logic, shown in KubeCon Demo, to base:resource module
