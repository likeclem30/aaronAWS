infra Cookbook
==============
cookbook to create aws environments using chef-provisioning.


Requirements
------------
Chef Management Box:
https://periscope-git-elb-503931483.us-east-1.elb.amazonaws.com/infra/chef-ppv/wiki/Create-Management-machine-for-chef-provision


Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### infra::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['infra']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### With Chef Server:
chef-client -r "recipe[infra]"
e.g.
For smoke environment recipe Just include `infra::smoke_env` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[infra::smoke_env]"
  ]
}
```
#### With Chef Zero:

chef-client -z infra/recipes/smoke_env.rb

#### Encryption
`'file_encryption_passphrase'` data bag item should be set under data bag `'db-secrets'` for file system encryption to work encryption to work


License and Authors
-------------------
Authors: Bhagyashree_S@external.mckinsey.com
         Kamalika_Majumdar@external.mckinsey.com
