#simple function to increment or decrement if given a negative value
#$newvar = add($var,"10")
#default is 1
module Puppet::Parser::Functions
    newfunction(:create_or_cat_ssh_key, :type => :rvalue) do |args|

        base = "/opt/semantico/data/ssh-keys"  # Where our keys are dumped
        makedir = base
        keytype = 'rsa'
        keybits = '1024'

        if args.size >= 2
            name = args[0]    # eg 'mikeadm', 'bbocp-production', 'rsyncer-production'
            type = args[1]    # pub, priv
            if type.to_s =~ /^priv/
                suffix = ''
            else 
                suffix = '.pub'
            end

            if args[2] == 'rsa' or args[2] == 'dsa'
                keytype = args[2]
            end

        elsif args.size == 1
            name = args[0]    # eg 'mikeadm', 'bbocp-production', 'rsyncer-production'
            suffix = '.pub'
        else
            raise Puppet::ParseError, "usage: create_or_cat_ssh_key(name, pub/priv)"
        end

        key_base = "#{base}/#{name}"
        key_file = "#{key_base}#{suffix}"

        unless File.file? key_file 
            out=%x{ssh-keygen -t #{keytype} -b #{keybits} -f #{key_base} }
        end

        # SSH Key files should now exist, as we should have created
        # it if it was not there already
        if File.file? key_file
            retvalue = File.read(key_file)
        else
            # FAIL!
            raise Puppet::ParseError, "create_or_cat_ssh_key: Could not open #{key_file} : #{out}"
        end
    end
end
