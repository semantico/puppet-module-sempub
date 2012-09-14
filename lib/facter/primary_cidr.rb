require 'facter'
require 'cidr'

Facter.add("primary_cidr") do
    confine :kernel => :linux
    result = " "
    setcode do   

        #match eth and bond devices dont rely on awk as it doesnt correctly chomp the output
        #evaluates true if match is found
        if netstat_output = %x( netstat -nr | head -n 100 | grep '^0.0.0.0') =~ /([e|b]\w*)\W/
            primary_nic = $1
        end    
        
        #TODO single regex with 2 matches? probably not as we might like these as separate facts
        if netstat_output = %x(ifconfig #{primary_nic} | grep Mask) =~ (/addr:([\d\.]*)\b/)
            primary_ip = $1
            
        end
        
        if netstat_output = %x(ifconfig #{primary_nic} | grep Mask) =~ (/Mask:([\d\.]*)\b/)
            primary_netmask = $1
        end
       
        #puts "primary_nic:" , primary_nic        
        #puts "primary_ip:" , primary_ip
        #puts "primary_netmask:" , primary_netmask
        
       # addrandmask2cidr
        result = Net::CIDR::addrandmask2cidr(primary_ip, primary_netmask) if (primary_nic && primary_ip && primary_netmask)
        result
    end
end
#
#if ARGV[0]
#    puts Facter.primary_cidr
#end
