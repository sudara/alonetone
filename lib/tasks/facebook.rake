# Copyright (c) 2007, Matt Pizzimenti (www.livelearncode.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Rake tasks modified from Evan Weaver's article
# http://blog.evanweaver.com/articles/2007/07/13/developing-a-facebook-app-locally

namespace "facebook" do

  namespace "tunnel" do

    ######################################################################################
    ######################################################################################
    desc "Start a reverse tunnel to develop from localhost. Please ensure that you have a properly configured config/facebook.yml file."
    task "start" => "environment" do
      
      remoteUsername = FACEBOOK['tunnel']['username']
      remoteHost = FACEBOOK['tunnel']['host']
      remotePort = FACEBOOK['tunnel']['port']
      localPort = FACEBOOK['tunnel']['local_port']
      sshPort = FACEBOOK['tunnel']['ssh_port'] || "22"
      
      puts "======================================================"
      puts "Tunneling #{remoteHost}:#{remotePort} to 0.0.0.0:#{localPort}"
            
      puts
      puts "NOTES:"
      puts "* ensure that you have Rails running on your local machine at port #{localPort}"
      puts "* once logged in to the tunnel, you can visit http://#{remoteHost}:#{remotePort} to view your site"
      puts "* use ctrl-c to quit the tunnel"
      puts "* if you have problems creating the tunnel, you may need to add the following to /etc/ssh/sshd_config on your server:"
      puts "
GatewayPorts clientspecified

"
      puts "* if you have problems with #{remoteHost} timing out your ssh connection, add the following lines to your '~/.ssh/config' file:"
      puts "
Host #{remoteHost}
  ServerAliveInterval 120

"
      puts "======================================================"
      exec "ssh -p #{sshPort} -nNT -g -R *:#{remotePort}:0.0.0.0:#{localPort} #{remoteUsername}@#{remoteHost}"
    end
    
    ######################################################################################
    ######################################################################################
    desc "Check if reverse tunnel is running"
    task "status" => "environment" do    
      sshPort = FACEBOOK['tunnel']['ssh_port'] || "22"
      if `ssh -p #{sshPort} #{FACEBOOK['tunnel']['username']}@#{FACEBOOK['tunnel']['host']} netstat -an | 
          egrep "tcp.*:#{FACEBOOK['tunnel']['port']}.*LISTEN" | wc`.to_i > 0
        puts "Tunnel still running"
      else
        puts "Tunnel is down"
      end
    end
  end


end