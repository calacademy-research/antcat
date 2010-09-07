require 'factory_girl'

Factory.define :ward_reference do |reference|
  reference.authors "Fisher, B.L."
  reference.year "2010"
  reference.title "Ants are my life"
  reference.citation "Informatica 21:3"
end

Factory.define :reference do |reference|
end

Factory.define :journal do |journal|
  journal.title 'Antographica'
end
