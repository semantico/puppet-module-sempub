#$newvar = convert_underscores_to_dashes("string_with_underscores")
module Puppet::Parser::Functions
    newfunction(:convert_underscores_to_dashes, :type => :rvalue) do |args|
        if args.size == 1
            return args[0].gsub(/_/, '-')
        else
            raise Puppet::ParseError, "convert_underscores_to_dashes: One argument required"
        end
    end
end
