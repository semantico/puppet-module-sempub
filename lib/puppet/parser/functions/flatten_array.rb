module Puppet::Parser::Functions
  
    # Flatten a tree of arrays (and scalars) passed as arguments
  newfunction(:flatten_array, :type => :rvalue) do |args|

    if args.size == 0
        raise Puppet::ParseError, "flatten_array: requires a list of arrays, or values to flatten into a single array"
    else
        return args.flatten
    end

  end
end
