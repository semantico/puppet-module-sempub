# $Id$
#
require 'facter'

Facter.add("resolvers") do
    confine :kernel => :linux
    setcode do
        result = open('/etc/resolv.conf').grep(/^nameserver ([0-9\.]+)/){$1}.join(',')
        #if more than one default gw found don't return anything
        result = " " unless result
        result
    end
end

