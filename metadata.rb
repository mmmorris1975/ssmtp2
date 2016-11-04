name 'ssmtp2'
maintainer 'Michael Morris'
maintainer_email 'michael.m.morris@gmail.com'
license '3-clause BSD'
description 'Installs/Configures ssmtp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.1'

%w(redhat centos fedora ubuntu debian).each do |p|
  supports p
end

depends 'yum-epel'
