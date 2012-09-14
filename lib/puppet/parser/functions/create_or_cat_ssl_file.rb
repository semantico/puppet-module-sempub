#simple function to increment or decrement if given a negative value
#$newvar = add($var,"10")
#default is 1
module Puppet::Parser::Functions
    newfunction(:create_or_cat_ssl_file, :type => :rvalue) do |args|

        base = "/opt/semantico/data/certs"  # Where our certs are dumped
        makedir = "/etc/semantico/CA"       # Where OpenSSL CA Makefile is
        bits = false # default 1024
        
        if args.size == 2
            cn = args[0]
            type = args[1]
            ssl_file = "#{base}/#{cn}.#{type}"
        #all a separate base subdirectory to be used
        elsif args.size == 3
            cn = args[0]
            type = args[1]
            subdir = args[2]
            basedir = "#{base}/#{subdir}"
            ssl_file = "#{basedir}/#{cn}.#{type}"
        #also allow 2048 bits to be specified
        elsif args.size == 4
            cn = args[0]
            type = args[1]
            subdir = args[2]
            basedir = "#{base}/#{subdir}"
            ssl_file = "#{basedir}/#{cn}.#{type}"
            bits = args[3]
        else
            raise Puppet::ParseError, "usage: create_or_cat_ssl_cert(CN, file_type, subdir, bits)"
        end

        # sanitize inputs
        unless ( cn =~ /^[-a-zA-Z0-9_\.]+$/ ) 
            raise Puppet::ParseError, "usage: create_or_cat_ssl_cert - CN must be of form ^[-a-zA-Z0-9_.]+$ (#{cn})"
        end

        unless File.file? ssl_file 
            # make our cert
            if Dir.chdir(makedir)
                if args.size == 2
                    out=%x{make cert CN="#{cn}" 2>&1}
                elsif args.size == 3
                    out=%x{make cert2 CN="#{cn}" SUBDIR="#{subdir}" 2>&1}
                elsif args.size == 4
                    out=%x{make cert3 CN="#{cn}" SUBDIR="#{subdir}" 2>&1}
                end
            else
                raise Puppet::ParseError, "create_or_cat_ssl_cert: Could not chdir into #{makedir}"
            end
        end

        # SSL file should now exist, as we should have created
        # it if it was not there already
        if File.file? ssl_file
            retvalue = open(ssl_file) { |f| f.read }
        else
            # FAIL!
            raise Puppet::ParseError, "create_or_cat_ssl_cert: Could not open #{ssl_file} : #{out}"
        end
    end
end
