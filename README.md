<div align="center">
	<p>
		<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/thoughtworks_flamingo_wave.png?sanitize=true" width=200 />
    <br />
		<img alt="DPS Title" src="https://raw.githubusercontent.com/ThoughtWorks-DPS/static/master/dps_lab_title.png?sanitize=true" width=350/>
	</p>
  <h3>lab-platform-eks-core-services</h3>
</div>
<br />

## current configuration

* metrics-server (v0.5.2)
* kube-state-metrics (v2.3.0)
* cluster-autoscaler (v1.21.2)
* create core system namespaces and roles
  * ns: lab-system
  * role: admin-clusterrole

### version updates

A nightly job runs health and versions checks. View log output for new version information.  

### lab-system

The `lab-system` namespace is reserved for the platform product teams use with cluster-wide services and testing.  

### admin-clusterrole

The `admin-clusterrole` is created with the default system:admin permissions and bound to the Github team group definition `ThoughtWorks-DPS/twdps-core-labs-team` to enable team members admin access when logging in via the dpscli platform tool.  
