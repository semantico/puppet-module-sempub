#$newvar = convert_dashes_to_underscores("string_with_underscores")
module Puppet::Parser::Functions
    newfunction(:convert_dashes_to_underscores, :type => :rvalue) do |args|
        if args.size == 1
            return args[0].gsub(/_/, '-')
        else
            raise Puppet::ParseError, "convert_dashes_to_underscores: One argument required"
        end
    end
end
