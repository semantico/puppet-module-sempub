# $Id$
#
require 'facter'

Facter.add("defaultgateway") do
    confine :kernel => :linux
    #GW we want a blank output by default
    result = " "
    setcode do
        result =  %x( netstat -nr | head -n 100 | grep '^0.0.0.0' | awk '{print $2}' ).chomp
        #if more than one default gw found don't return anything
        result = " " if result =~ /\n\d/
        result
    end
end

