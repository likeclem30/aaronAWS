name             'pv-web-role'
maintainer       'Periscope Solutions'
maintainer_email 'dev@periscope-solutions.com'
license          'All rights reserved'
description      'Installs/Configures pv-web-role'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://git.mckinsey-solutions.com/infra/periscope-environments'
issues_url       'https://git.mckinsey-solutions.com/infra/periscope-environments/issues'
version          '0.1.0'
depends 'pv-web'
depends 'pv-web-assets'
depends 'mash-splunk'
