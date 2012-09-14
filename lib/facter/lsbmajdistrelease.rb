# $Id$
#
require 'facter'

Facter.add("lsbmajdistrelease") do
    confine :kernel => :linux
    setcode do
        if /(\d*)\./i =~ Facter.lsbdistrelease
            result=$1
        else
            result=Facter.lsbdistrelease
        end
        result
    end
end

