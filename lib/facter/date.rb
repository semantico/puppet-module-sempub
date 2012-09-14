# $Id$
#
require 'facter'

Facter.add("date") do
    confine :kernel => :linux
    setcode do
        four_digit_year_date = '%Y%m%d'
        now = Time.now
        now.strftime(four_digit_year_date)
    end 
end

