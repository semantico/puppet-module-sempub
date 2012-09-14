module Puppet::Parser::Functions
  
    # Flatten a tree of arrays (and scalars) passed as arguments
  newfunction(:array_contains, :type => :rvalue) do |args|

    if args.size != 2
        raise Puppet::ParseError, "Usage: array_contains(array, lvalue): return true if array contains lvalue, false otherwise"
    end

    array_to_check = args[0]
    string_to_find = args[1]

    unless array_to_check.instance_of?(Array)
        raise Puppet::ParseError, "Usage: array_contains(array, lvalue): return true if array contains lvalue, false otherwise"
    end

    unless string_to_find.instance_of?(String)
        raise Puppet::ParseError, "Usage: array_contains(array, string): return true if array contains string, false otherwise"
    end

    if array_to_check.grep(string_to_find).size > 0
        return true
    else
        return false
    end

  end
end
