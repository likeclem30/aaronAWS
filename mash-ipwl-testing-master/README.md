# Mash-Cookbook-IPWL

This cookbook provides with IP Whitelisting Solution in compliance with MASH requirements.
The feautures supported by this cookbook are:
- IP Whitelisting Control for Akamai and Non Akamai setups
- Support of ZScaler IP identification by Cookie Planting
- Some Generic Routing Capabilities

# Sites Configuration

The configuration can be done via attributes or S3 files.
Each site has one domain. And each domain can have many locations (it needs at least one location).
Each location has the following parameters:
- **name**: The path of the location in nginx (eg: /).
- **protocol**: This can be http, https or both. If location protocols change the configuration two locations with the same name can be created (one with http and the other with https).
- **remote_protocol**: The protocol used to reach the remote_url. It can be keep, http or https. This field is only meaningful if remote_url is not None.
- **remote_url**: The remote url to be proxy_passed. "None" if not used.
- **pass_host**: To pass the host header to proxy_pass or not.
- **redirection**: This can be URL, ProtocolChange or None if no redirection is required. Protocol change will redirect to the current url but with a different protocol. You cannot use both remote_url and redirection together successfully.
- **redirection_code**: This can be 301 or 302 redirection code.
- **redirection_url**: The url you want to set the redirection to using Location header and a HTTP 30X code. This field is only meaningful if redirection is not None.
- **reject_url**: This is the url to be used in this location if the authentication of the origin IP fails. This redirection overrides any other configuration of the location because the user it not authenticated and hence must not access any further.

## Attributes configuration

Sites configuration is defined in the node['mash-ipwl']['sites'].

Example:
```
default['mash-ipwl']['sites'] = { "site1" => { "domain" => "akamai.example.com",
          				       "type" => "akamai",
          				       "locations" => [
                        			  { "name" => "/",
                        			        "protocol" => "both",
                       				        "remote_protocol" => "keep",
                     				        "remote_url" => "None",
                     				        "pass_host" => true,
                    				        "redirection" => "URL",
                    				        "redirection_code" => "302",
                    				        "redirection_url" => "http://google.com",
                    				        "reject_url" => "http://www.mckinseysolutions.com/"
                    			          },
                       			          { "name" => "/app1",
                          			        "protocol" => "both",
                        		       	        "redirection" => "None",
                       		                        "remote_protocol" => "keep",
                      					"remote_url" => "yahoo.com",
                      					"pass_host" => true,
                      				        "reject_url" => "http://www.mckinseysolutions.com/"
                          			  }
                         				],
						 },
				    "site2" => { "domain" => "nonakamai.example.com",
          					  "type" => "nonakamai",
          					"locations" => [
                        			  { "name" => "/",
                        			        "protocol" => "both",
                       				        "remote_protocol" => "keep",
                     				        "remote_url" => "None",
                     				        "pass_host" => false,
                    				        "redirection" => "URL",
                    				        "redirection_code" => "302",
                    				        "redirection_url" => "http://google.com",
                    				        "reject_url" => "http://www.mckinseysolutions.com/"
                    			           },
                       			           { "name" => "/app1",
                          				  "protocol" => "both",
                        				  "redirection" => "None",
                       					  "remote_protocol" => "keep",
                      					  "remote_url" => "yahoo.com",
                      					  "pass_host" => false,
                      				          "reject_url" => "http://www.mckinseysolutions.com/"
                          			    }
                         			   ],
					          }
				}
```

## S3 Sites Configuration

The S3 configuration works by merging sites configurations present in a S3 folder. It is thought for bigger setups with many sites. Each JSON file can contain one or many sites and the file format will be exactly the JSON transformation of the Ruby Hash attribute format.

Example:
```
default['mash-ipwl']['s3_sites'] = 's3://bucket/ipwl/sites_config'
```

# IP Whitelist and Trusted Proxies Configuration

IP Whitelist and Trusted Proxies operate a location level (for example /app1 in site1 => domainsite1.com/app1). There is no disctinctions of origin protocol. Because of ZScaler restrictions we are forced to open HTTP as well to validate this use case.

In a similar fasion to sites configuration it can be done via attributes or via S3 files.

## Attributes configuration

Attributes based configuration is based for debugging or test & dev use cases.

Examples:
```
default['mash-ipwl']['ip_whitelist'] = {
                                        "akamai.example.com" => {
                                                                  "/" => { "ips" => ["80.169.207.10"]},
                                                                  "/app" => { "ips" => ["80.34.208.178"]}
                                                                 },
                                        "nonakamai.example.com" => {
                                                                   "/" => { "ips" => ["80.169.207.10"]},
                                                                    "/app" => { "ips" => ["80.34.208.178"]}
                                                                 }
										}
defaul['mash-ipwl']['trusted_proxies'] = {
                                       "akamai.example.com" => {
                                                                  "/" => { "ips" => ["80.169.207.10"]},
                                                                  "/app" => { "ips" => ["80.34.208.178"]}
                                                                 },
                                        "nonakamai.example.com" => {
                                                                   "/" => { "ips" => ["80.169.207.10"]},
                                                                    "/app" => { "ips" => ["80.34.208.178"]}
                                                                 }
										}
```

## S3 Configuration

S3 Configuration is thought for production use cases. IP Whitelist and Trusted Proxies are configured by pointing to specifics folders in S3.

Example:
```
default['mash-ipwl']['ip_whitelist_config'] = 's3://bucket/ipwl/allowed_ips'
default['mash-ipwl']['trusted_proxies_config'] = 's3://bucket/ipwl/trusted_proxies'
```

The format of the files will be CSV. Each line will match an IP or IP Range. The scope of the file is defined at the file name level following this format:
- **global__xxxx**: The content of this file applies to every location in every site. xxxx is a human friendly tag to know the content of the file.
- **domain.com__app--folder1--folder2**: The content of this file applies to the domain.com in the location /app/folder1/folder2 for example http://domain.com/app/folder1/folder2
