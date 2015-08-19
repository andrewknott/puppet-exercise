#init.pp
#
#Puppet manifest that will download exercise content, download and configure nginx and start nginx to server the content.
#Will also set SELinux to peermissive. 
#

#Manual utility package - wget to pull from the web.
package { 'wget':
  ensure => present,
}

#Ensure git pacakge is around to clone the exercise content.
package { 'git':
  ensure => present,
} ->
#Clone the content from exercise git repo
vcsrepo { '/usr/share/nginx/html/exercise':
  ensure     => latest,
  provider   => git,
  source     => 'git://github.com/puppetlabs/exercise-webpage',
  revision   => 'master',
}

#Disable SELinux - nginx will not start if SELinux is in enforce mode - https://www.nginx.com/blog/nginx-se-linux-changes-upgrading-rhel-6-6/
exec { 'setenforce 0 | true':
  #Do not run if sestatus does not exist or SELinux is not in enforcing mode
  unless  => "test -x /usr/sbin/sestatus && sestatus | grep ^Current | grep -v enforcing",
  path => "/usr/sbin:/usr/bin",
} ->

#Ensure that nginx is installed. Version and processor dependency.
package { 'nginx':
ensure => present,
source => "http://nginx.org/packages/rhel/7/x86_64/RPMS/nginx-1.8.0-1.el7.ngx.x86_64.rpm",
provider => rpm,
} ->

#change nginx listening port to 8000
file_line { 'nginx_port':
  path => '/etc/nginx/conf.d/default.conf',
  line => 'listen 8000;',
  match => '^[\s]*listen.*',
  after => 'server ',
  multiple => 'false',
  require => Package['nginx'],
} ->

#Change nginx path for content to exercise path
file_line { 'nginx_path':
  path => '/etc/nginx/conf.d/default.conf',
  line => 'root   /usr/share/nginx/html/exercise;',
  match => '^[\s]*root.*',
  after => 'location ',
  multiple => 'true',
  require => File_line['nginx_port'],
} ->

#Start the web server
service { "nginx.service":
  ensure => "running",
}

