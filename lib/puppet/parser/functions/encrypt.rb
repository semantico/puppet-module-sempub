#create a md5 hash compatible with apache htpasswd files and shadow entries using a random salt.

#short version
#args[0].crypt( ([]*8).inject("$1$") { |r,_| r += ([".","/"] + [*"0".."9"] + [*"A".."Z"] + [*"a".."z"])[rand(64)]} )
#mkpasswd version
#%x{/usr/bin/mkpasswd -H MD5 #{args[0]} salt }.chomp

#require 'digest/md5'

module Puppet::Parser::Functions
    newfunction(:encrypt, :type => :rvalue) do |args|
        # compatible random chars to make a salt from 
        salting_chars = ['.', '/'] + ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
        
        #tell crypt to use MD5
        salt+=("$1$")
        #build a random 8 char salt
        8.times { salt += salting_chars[rand(64)] }        
        salt+=("$")
        args[0].crypt( salt )    
    end
end


##############USAGE

#$pw = shadow("test")
#notify { $pw: }