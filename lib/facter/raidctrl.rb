# raidctrl.rb

Facter.add("raidctrl") do
    confine :kernel => :linux
    setcode do
        ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
        raidctrl_name = "none"
        lspciexists = system "which lspci >/dev/null"
        if $?.exitstatus == 0

            # 3ware
            check_3ware = %x{lspci -d '13c1:' 2>/dev/null}.to_s
            if check_3ware.include?("SATA-RAID")
                    raidctrl_name = "3ware_raid"
            end


            # hp smartarray / cciss
            check_cciss = %x{lspci -d '103c:' 2>/dev/null}.to_s
            if check_cciss.include?("Smart Array") or check_cciss.include?("3238") then
                    raidctrl_name = "cciss"
            end

            # areca raid
            check_areca = %x{lspci -d '17d3:' 2>/dev/null}.to_s
            if check_areca.include?("RAID") then
                    raidctrl_name = "areca"
            end

            #re-enable when check_raid is working
            #We use software raid with this card
            # Adaptec
            #check_adaptec = %x{/usr/bin/lspci -d '9005:' 2>/dev/null}.to_s
            #if check_adaptec.include?("U320") then
            #        raidctrl_name = "adaptec_U320"
            #end

            #Dell
            check_dell = %x{lspci -d '1028:' 2>/dev/null}.to_s
            if check_dell.include?("Dell PowerEdge Expandable RAID controller 5") then
                    raidctrl_name = "lsi_megasas"
            end

            #LSI
            #http://hwraid.le-vert.net/wiki/LSI
            check_lsi = %x{lspci -d '1000:' 2>/dev/null}.to_s
            if check_lsi.include?("Fusion-MPT Dual Ultra320") then
                    raidctrl_name = "lsi_mpt_fusion_u320"
            elsif check_lsi.include?("MegaRAID SAS") then
                    raidctrl_name = "lsi_megasas"
            elsif check_lsi.include?("SAS1078 PCI-X Fusion-MPT SAS") then
                    raidctrl_name = "lsi_megasas"
            elsif check_lsi.include?("MegaRAID") then
                    raidctrl_name = "lsi_megaraid"
            elsif check_lsi.include?("LSI MegaSAS") then
                    raidctrl_name = "lsi_megasas"
            end

            ######### Test for virtual machines
            output = %x{lspci}
            output.each {|p|
                        # --- look for the vmware video card to determine if it is virtual => vmware.
                        # ---     00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter
                        raidctrl_name = "virtual" if p =~ /VMware/i
            }

            # linux software raid
            check_linuxmd = ((%x{cat /proc/mdstat 2>/dev/null}.to_s =~ /^md.*: .*raid/m) != nil)
            if check_linuxmd then
                    raidctrl_name = "linuxmd"
            end
            
            
        end

        result = raidctrl_name
    end
    
end
