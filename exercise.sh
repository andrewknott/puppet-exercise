#!/bin/bash
# exercise.sh - Puppet Labs SE tech challenge
# Two parts -  this exercise.sh file and init.pp
#
# exercise.sh installs and configures standalone puppet, downloads init.pp from github, runs puppet apply and tests the web server.
# init.pp - Puppet manifest that downloads exercise content, downloads and configures nginx and starts nginx to server the content.
# 
# Assumptions: 
# - works on RHEL 7, x64 only.
# Bare bones box with yum installed.
# Works with SELinux installed and with enforcing policy


#Set YUM repo to the best version of puppet
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
#Install Puppet standalone
sudo yum -y install puppet

#Start puppet now and on boot - good hygiene
sudo puppet resource service puppet ensure=running enable=true

#import modules used in the exercise - standard-lib and version control (git)
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-vcsrepo

#Either download init.pp from github using this curl/wget, or manually edit a file called init.pp using your favorite editor: pico/vi/cat...
if test ! -s init.pp 
then
  curl 'https://raw.githubusercontent.com/andrewknott/puppet-exercise/master/init.pp' > init.pp || wget 'https://raw.githubusercontent.com/andrewknott/puppet-exercise/master/init.pp'
fi

if test ! -s init.pp 
then
  echo "Error, could not download https://raw.githubusercontent.com/andrewknott/puppet-exercise/master/init.pp" 
  echo "Please copy https://raw.githubusercontent.com/andrewknott/puppet-exercise/master/init.pp into this directory"  
  echo "or install curl or wget and connect to the internet."
else 

  #Run the puppet manifest
  sudo puppet apply -v `pwd`

  #Test the web server.
  echo .
  echo Finished, continuing in 5 seconds...
  echo .
  sleep 5
  echo .
  echo Is the web server listening on 8000:
  echo .
  netstat -an | grep tcp | grep -i listen
  echo .
  echo Downloading the web page in 5 seconds...
  sleep 5
  wget -q -O - http://localhost:8000
  
fi
