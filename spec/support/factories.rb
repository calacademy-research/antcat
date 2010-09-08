require 'factory_girl'

Factory.define :ward_reference do |reference|
  reference.authors "Fisher, B.L."
  reference.year    "2010"
  reference.title   "Ants are my life"
  reference.sequence(:citation) {|n| "Informatica 21:#{n}"}
end

Factory.define :reference do |reference|
end

Factory.define :journal do |journal|
  journal.title 'Antographica'
end
