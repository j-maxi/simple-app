import (
	"github.com/j-maxi/designpattern-as-code/kubernetes:base"
)

module: {
	repository: "https://github.com/j-maxi/designpattern-as-code"
	revision:   string @tag("designpatternRevision")
}

gcp: {
	projectID: "solarray-dev-14186193"
	cluster: {
		name:   "solar-ray01-dev01-master"
		region: "asia-northeast1"
	}
}

params: {
	appName:    "kubecon-demo-app"
	namespace:  "kubecon-demo"
	image:      "gcr.io/\(gcp.projectID)/kubecon-demo"
	repository: "https://github.com/j-maxi/simple-app"
	revision:   string @tag("revision")
}

composites: [
	base.DesignPattern & {
		parameters: {
			appName:                 params.appName
			namespace:               params.namespace
			image:                   params.image
			repository:              params.repository
			revision:                params.revision
			designpatternRepository: module.repository
			designpatternRevision:   module.revision
			gcpProjectID:            gcp.projectID
			gcpRegion:               gcp.cluster.region
			clusterName:             gcp.cluster.name
		}
	},
]

results: _
for _, c in composites {
	results: resources: c.resources
	results: tasks:     c.tasks
}

toTektonTask: {
	tasks:  _ | *[]
	before: _ | *[]
	out: [
		for _, t in tasks {
			t & {
				runAfter: [ for _, b in before {b.name}]
			}
		},
	]
}

tektonPipeline: {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: "deploy-with-designpattern"
	//spec: tasks: _

	// build
	_buildtasks: (toTektonTask & {
		tasks: results.tasks.build
	}).out

	_deploytasks: (toTektonTask & {
		tasks:  results.tasks.deploy
		before: _buildtasks
	}).out

	_checktasks: (toTektonTask & {
		tasks:  results.tasks.check
		before: _deploytasks
	}).out

	spec: tasks: _buildtasks + _deploytasks + _checktasks
}

kubernetesManifests: {
	apiVersion: "v1"
	kind:       "List"
	items: [ for _, m in results.resources.kubernetes {m}]
}
