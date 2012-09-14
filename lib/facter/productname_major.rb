# $Id$
#
require 'facter'

Facter.add("productname_major") do
    confine :kernel => :linux
    setcode do
        result = "unknown"
        begin
            #edge case for oem unbranded boxes
            if Facter.productname == "To Be Filled By O.E.M."
                result = "unavailable"
            elsif Facter.virtual == "vmware"
                result ="Vmware"
            else
                #trim the product name to the first component which is the server range in the case of hp and dell servers
                result = Facter.productname.gsub(/ .*/, '')
            end
        rescue
                begin
                    if Facter.base_board_information_manufacturer_major == "Intel"
                        result ="Intel"
                    else
                        result = "unavailable"
                    end    
                rescue
                    result = "unavailable"
                end
        end
        result
    end 
end
