require 'facter'

if FileTest.exists?("/usr/sbin/dmidecode")
    #Examples
    #Base Board Information
    #Manufacturer: TYAN
    #Product Name: S2881 Thunder K8SR Mainboard

    # Add remove things to query here
    query = { 'Chassis Information' => ['Manufacturer:'], 'Base Board Information' => ['Manufacturer:', 'Product Name:'], 'BIOS Information' =>  [ 'Release Date:'],'IPMI' =>  [ 'Interface Type:'] }

    # Run dmidecode only once
    output=%x{/usr/sbin/dmidecode 2>/dev/null}
    #puts output
    query.each_pair do |key,v|
        v.each do |value|
            #split the dmidecode output into chunks
            output.split("Handle").each do |handle_chunk|
                #search each chunk for a key and value in the query hash
                if handle_chunk =~ /#{key}/  and handle_chunk =~ /#{value} (\w.*)\n*./
                    #make sure we return the dmidecode value without any trailing whitespace..
                    result = $1.to_s.strip
                    
                    #debug
                    #puts key.downcase.chomp(':').gsub(/ /,'_') + "_" + value.downcase.chomp(':').gsub(/ /,'_')
                    #puts result
                    
                    #Special case for certain entries to be useful in puppet taking the first word of this dmidecode value and tagging it as major
                    #e.g base_board_information_manufacturer Dell .Inc =>base_board_information_manufacturer_major  Dell
                    if value =~ /(Product Name)|Manufacturer|Vendor/
                            #debug
                            #puts key.downcase.chomp(':').gsub(/ /,'_') + "_" + value.downcase.chomp(':').gsub(/ /,'_') + "_major"
                            #puts result.gsub(/ .*/, '')

                            Facter.add(key.downcase.chomp(':').gsub(/ /,'_') + "_" + value.downcase.chomp(':').gsub(/ /,'_') + "_major") do
                                confine :kernel => :linux
                                setcode do
                                    result.gsub(/ .*/, '')
                                end
                            end
                    end
                    #build the facter variable name from the dmidecode group, and the specific value
                    Facter.add(key.downcase.chomp(':').gsub(/ /,'_') + "_" + value.downcase.chomp(':').gsub(/ /,'_')) do
                        confine :kernel => :linux
                        setcode do
                            result
                        end
                    end
                end 
            end
        end
    end
end
