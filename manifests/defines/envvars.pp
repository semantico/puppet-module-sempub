#   
# * Copyright (c) 2008, Mike Pountney (Mike.Pountney@semantico.com)
# * All rights reserved.
# *
# * Redistribution and use in source and binary forms, with or without
# * modification, are permitted provided that the following conditions are met:
# *     * Redistributions of source code must retain the above copyright
# *       notice, this list of conditions and the following disclaimer.
# *     * Redistributions in binary form must reproduce the above copyright
# *       notice, this list of conditions and the following disclaimer in the
# *       documentation and/or other materials provided with the distribution.
# *     * Neither the name of the <organization> nor the
# *       names of its contributors may be used to endorse or promote products
# *       derived from this software without specific prior written permission.
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY
# * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

# These defines aide adding global environment variables to systems that support
# it - usually via the /etc/environment file.
#
# RHEL3 is not currently supported.
#
# 


define environment_var_standard ( $name, $value, $ensure ) {
    line { "_environment_var_standard_$name":
        file => "/etc/environment",
        line => "${name}=${value}",
        ensure => $ensure,
    }
}

define environment_var ( $name, $value, $ensure = 'present' ) {

    case $operatingsystem {
        redhat: { 
            case $lsbdistrelease {
                3: { }
                default: { 
                    environment_var_standard { "$name": name => $name, value => $value, ensure => $ensure } 
                }
            }
        }

        centos: { 
            case $lsbdistrelease {
                3: { }
                default: { 
                    environment_var_standard { "$name": name => $name, value => $value, ensure => $ensure } 
                }
            }
        }

        default: {
            environment_var_standard { "$name": name => $name, value => $value, ensure => $ensure } 
        }
    }

}
