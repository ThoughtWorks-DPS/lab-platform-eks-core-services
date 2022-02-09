<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/dps_lab_title.png?sanitize=true" width=350/>
	</p>
  <h3>lab-platform-eks-core-services</h3>
    <a href="https://app.circleci.com/pipelines/github/ThoughtWorks-DPS/lab-platform-eks-core-services"><img src="https://circleci.com/gh/ThoughtWorks-DPS/lab-platform-eks-core-services.svg?style=shield"></a> <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
</div>
<br />

## current configuration

* metrics-server
* kube-state-metrics
* cluster-autoscaler
* aws-efs-csi-driver
* datadog agents (pending)
  * core eks system-level monitoring
  * Eks, Addons, core system service version check and alerting
* create core system resources
  * ns: lab-system
  * role: admin-clusterrole
  * efs storage class
  * ebs storage class

### version updates

A nightly job runs health and versions checks. View log output for new version information.  

### lab-system

The `lab-system` namespace is reserved for the platform product teams use with cluster-wide services and testing.  

### admin-clusterrole

The `admin-clusterrole` is created with the default system:admin permissions and bound to the Github team group definition `ThoughtWorks-DPS/twdps-core-labs-team` to enable team members admin access when logging in via the dpscli platform tool.  
