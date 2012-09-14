#simple function to increment or decrement if given a negative value
#$newvar = add($var,"10")
#default is 1
module Puppet::Parser::Functions
    newfunction(:add, :type => :rvalue) do |args|
        if args[1]
            increment=args[1].to_i
        else
            increment=1
        end
        retvalue = args[0].to_i + increment
        retvalue
    end
end