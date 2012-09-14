#!/usr/bin/env ruby
# Return the uid of a given user.
#

group = 'users'

require 'facter'
require 'etc'
	
Facter.add("gid_#{group}") do
    confine :kernel => :linux
    setcode do
    
        begin
            Etc.getgrnam(group).gid
        rescue ArgumentError
        end

    end
end
