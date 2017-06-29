#### BOSH Halo Release

This is a release repository for BOSH that deploys the Halo Agent application.

#### RELEASE 'cloudpassage'

```
url: https://github.com/cloudpassage/cloudpassage-bosh/raw/master/releases/cloudpassage/cloudpassage-5.tgz
sha1: e3bb073ba8953531eb9089cda3652b0d2dcb43c2
```

or

```
bosh upload release releases/cloudpassage/cloudpassage-4.tgz
```

#### Prerequisites: (if you dont already have a BOSH environment initialized):

1. Here's a setup tutorial for AWS (https://bosh.io/docs/init-aws.html)
2. Install BOSH CLI gem `gem install bosh_cli`
3. Let the CLI know about bosh Director `bosh target <director_ip_address>` (use admin/admin to log in)

#### Getting Started:

Each BOSH deployment needs to provide a specially structured configuration file - deployment manifest.

Required Halo configuration variables to put into the manifest:

1. agent_key=agent_key (value of your agent key)
2. aws_server_label=0

Optional Halo configuration variable:

1. server_tag=

Here is a sample manifest that utilizes AWS.

```
---
name: halo # <--- Replace with your own deploy name
director_uuid: '' # <--- Replace with Director UUID

releases:
- name: cloudpassage
  version: '' # <--- Replace with the latest release version

networks:
- name: default
  type: dynamic
  cloud_properties:
    subnet: '' # <--- Replace with AWS subnet id

resource_pools:
- name: default
  network: default
  stemcell:
    name: '' # <--- Replace with Stemcell name
    version: latest
  cloud_properties:
    instance_type: m3.medium
    availability_zone: # <--- Replace with your AWS region, ie. us-west-1b
    auto_assign_public_ip: true

compilation:
  workers: 2
  network: default
  cloud_properties:
    availability_zone: # <--- Replace with your AWS region, ie. us-west-1b
    instance_type: m3.medium

update:
  canaries: 1
  canary_watch_time: 60000-180000
  update_watch_time: 60000-180000
  max_in_flight: 2

jobs:
- name: cp_halo
  templates:
  - name: cp_halo
  instances: 1
  resource_pool: default
  networks:
  - name: default
  properties:
    aws:
      access_key_id: '' # <--- Replace with AWS Access Key ID
      secret_access_key: '' # <--- Replace with AWS Secret Key
      default_key_name: '' # <--- Replace with SSH key name
      default_security_groups: [] # <--- Replace with AWS Security Group name
      region: ''  # <--- Replace with Region, ie. us-west-1

properties:
  cp_halo:
    agent_key: '' # <--- Replace with Halo Agent Key
    aws_server_label: 0
    server_tag: '' # <--- Replace with optional Halo server tag
```


#### Create BOSH Release

After the manifest content is fully populated, the next step is to create a release.

1. `bosh upload release releases/cloudpassage/cloudpassage-2.yml` Upload the generated release to the director.

```
Acting as user 'admin' on 'my-bosh'

+----------------+-----------+-------------+
| Name           | Versions  | Commit Hash |
+----------------+-----------+-------------+
| cloudpassage   | 3         | fb02fe8a+   |
+----------------+-----------+-------------+
(*) Currently deployed
(+) Uncommitted changes

Releases total: 1
```

### Set Deployment Manifest

1. `bosh status --uuid` Update the director_uuid value in the manifest.yml with the value
2. `bosh deployment manifest.yml` Set the deployment manifest

### Upload stemcell

Official BOSH stemcells are maintained with security updates at bosh.io.


1. `bosh upload <stemcell.tgz>` Upload stemcell to Director:
2. `bosh stemcells` See Uploaded Stemcells:

```
Acting as user 'admin' on 'my-bosh'

+---------------------------------------------+---------------+---------+--------------+
| Name                                        | OS            | Version | CID          |
+---------------------------------------------+---------------+---------+--------------+
| bosh-aws-xen-centos-7-go_agent              | centos-7      | 3312    | ami-b33b6fd3 |
| bosh-aws-xen-ubuntu-trusty-go_agent         | ubuntu-trusty | 3309*   | ami-ff683d9f |
| bosh-warden-boshlite-ubuntu-trusty-go_agent | ubuntu-trusty | 3309    | ami-856e3be5 |
+---------------------------------------------+---------------+---------+--------------+

(*) Currently in-use

Stemcells total: 3
```


#### Deploy

1. `bosh deploy`

```
Deploying
---------

Director task 729
Deprecation: Ignoring cloud config. Manifest contains 'networks' section.

  Started preparing deployment > Preparing deployment. Done (00:00:00)

  Started preparing package compilation > Finding packages to compile. Done (00:00:00)

  Started compiling packages > cp_halo/99d59c7894951c76cf497dfd9514e887b209c710. Done (00:02:41)

  Started creating missing vms > cp_halo/654ebee1-ba0a-4016-9e53-dd5942528f00 (0). Done (00:01:25)

  Started updating instance cp_halo > cp_halo/654ebee1-ba0a-4016-9e53-dd5942528f00 (0) (canary). Done (00:01:57)

Task 729 done

Started   2016-11-22 19:07:33 UTC
Finished  2016-11-22 19:13:37 UTC
Duration  00:06:04

Deployed 'halo' to 'my-bosh'
```

<!---

#CPTAGS:community-supported deployment
#TBICON:images/partner-supported.png
-->
