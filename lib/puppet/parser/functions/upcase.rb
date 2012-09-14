#simple function to increment or decrement if given a negative value
#$newvar = upcase("string")
module Puppet::Parser::Functions
    newfunction(:upcase, :type => :rvalue) do |args|
        if args.size == 1
            return args[0].to_s.upcase
        else
            raise Puppet::ParseError, "capitalize: One argument required"
        end
    end
end
