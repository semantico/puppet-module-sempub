module Puppet::Parser::Functions
    newfunction(:create_and_print_password, :type => :rvalue) do |args|

        base = "/opt/semantico/data/passwords"  # Where our passwords are dumped
        retvalue = "X"

        if args.size == 1
            key = args[0]
            type = "plain"
            pwlen = 20
        elsif args.size == 2
            key = args[0]
            type = args[1]
            pwlen = 20
        elsif args.size == 3
            key = args[0]
            type = args[1]
            pwlen = args[2]
        else
            raise Puppet::ParseError, "usage: create_and_print_password({unique-key}, [hash-type: des-salt, md5-salt, plain, postgres], [password-length])"
        end

        if key !~ /^[a-zA-Z0-9\-_]+$/
            raise Puppet::ParseError, "create_and_print_password: key can only contain chars a-zA-Z0-9-_ (key specified: #{key})"
        end

        pw_file = "#{base}/#{key}"
        salt_file = "#{base}/#{key}.salt"

        unless File.file? pw_file 
            out=%x{pwgen -A -N 1 -n #{pwlen} > #{pw_file}}
        end

        unless File.file? salt_file 
            POSSIBLE = [('a'..'z'),('A'..'Z'),(0..9)].inject([]) {|s,r| s+Array(r)}
            new_salt = Array.new(8) { POSSIBLE[ rand(POSSIBLE.size) ] }.to_s
            open(salt_file, 'w') do |f|
                f.puts new_salt
            end
        end

        # password file should now exist, as we should have created
        # it if it was not there already
        password = ""
        if File.file? pw_file
            password = open(pw_file) { |f| f.read }
            password.chomp!
        else
            raise Puppet::ParseError, "create_and_print_password: Could not open #{pw_file} : #{out}"
        end

        salt = ""
        if File.file? salt_file
            salt = open(salt_file) { |f| f.read }
            salt.chomp!
        else
            raise Puppet::ParseError, "create_and_print_password: Could not open #{salt_file} : #{out}"
        end

        if type == "plain"
            retvalue = password
        elsif type == "des-salt"
            retvalue = password.crypt(salt.slice(0,2)) # to get DES out of crypt, use a 2-char salt
        elsif type == "md5-salt"
            retvalue = password.crypt("\$1\$#{salt}")  # $1$+8char gets you MD5 from crypt
        else 
            raise Puppet::ParseError, "create_and_print_password: password type #{type} not supported, yet!"
        end

        if retvalue.length < 3 
            raise Puppet::ParseError, "create_and_print_password: error retrieving password with key '#{key}'"
        end 

        retvalue

    end
end
