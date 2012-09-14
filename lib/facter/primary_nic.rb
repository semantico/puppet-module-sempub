
require 'facter'

Facter.add("primary_nic") do
    confine :kernel => :linux
    #GW we want a blank output by default
    result = " "
    setcode do
        #match eth and bond devices dont rely on awk as it doesn't correctly chomp the output
        if netstat_output = %x( netstat -nr | head -n 100 | grep '^0.0.0.0') =~ /([e|b]\w*)\W/
            result = $1
        end
        result
    end
end
#if ARGV[0]
#   puts Facter.primary_nic
#end
