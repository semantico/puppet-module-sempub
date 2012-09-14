# $Id$
#
require 'facter'

Facter.add("productname_model") do
    confine :kernel => :linux
    setcode do
        result = "unknown"
        begin
            #edge case for DNUK boxes
            if Facter.productname == "To Be Filled By O.E.M."
                result = " "
            elsif Facter.virtual == "vmware"
                result =" "
            else
            #trim the product name to the second component which is the model
                Facter.productname =~ / (.*)$/
                result = $1
                #remove any trailing whitespace (dell models)
                result = result.strip.chomp
            end
        rescue
            #possibly productname wasn't able to be retrieved..
            result = "unavailable"
        end
        
        result
    end 
end
