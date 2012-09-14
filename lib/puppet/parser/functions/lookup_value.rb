module Puppet::Parser::Functions
  # Read a value from a file of key: value pairs.  Value may be a comma
  # separated list.  If more than one value is present, a list will be
  # returned.  The last match found will be returned.  A default value
  # may be specified in case the key is not found.  Normally, nil will
  # be returned if the key is not found.
  newfunction(:lookup_value, :type => :rvalue) do |args|
    key = args[0]
    default = args[1]
    file = args[2] || '/etc/puppet/manifests/lookup/lookup_value.db'
    hostname = lookupvar('hostname')

    return default if !File.exist?(file)

    # Dear puppet, please keep an eye on this one. (only pre 2.6)
    if lookupvar('serverversion') =~ /^0\.25/
      parser.watch_file(file)
    end

    rv = nil


    begin
      IO.foreach(file) do |line|
        line.chomp!
        if line =~ /^([-_A-Za-z0-9]+)\s*:\s*(.+)\s*$/
            k = $1
            v = $2

            if ( k == "#{key}-#{hostname}" )
              vals = v.split(/\s*,\s*/)
              rv = vals.length == 1 ? vals[0] : vals
              Puppet.warning("#{k} read matched to: #{rv}")
            elsif (k == key)
              vals = v.split(/\s*,\s*/)
              rv = vals.length == 1 ? vals[0] : vals
              Puppet.warning("#{key} read matched to: #{rv}")
            end
        elsif line =~ /^([-_A-Za-z0-9]+)\s*:\s*$/
            k = $1
            if (k == "#{key}-#{hostname}" or k == key)
                rv = ""
            end
        end

      end

      if rv == nil then
          if default == nil
              raise Puppet::ParseError, "lookup_value: Could not find value for #{key} and no default provided"
          else
              Puppet.warning("Default used: #{default}")
              rv = default
          end
      end

      # return actual booleans
      rv = true if rv == 'true'
      rv = false if rv == 'false'

      return rv

    rescue Exception => e
      raise Puppet::ParseError, "lookup_value: error reading #{file}: #{e}"
    end
  end
end
