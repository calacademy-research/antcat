require 'factory_girl'

Factory.define :reference, :default_strategy => :build do |reference|
  reference.authors "Fisher, B.L."
  reference.year "2010"
  reference.title "Ants are my life"
  reference.citation "Informatica 21:3"
end

