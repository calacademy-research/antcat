require 'factory_girl'

Factory.define :reference do |reference|
  reference.citation_year    "2010"
  reference.title   "Ants are my life"
  reference.year  2010
  reference.after_build do |article|
    source.authors << Factory(:author)
  end
end

Factory.define :author do |author|
  author.sequence(:name) {|n| "Fisher#{n}, B.L."}
end

Factory.define :journal do |journal|
  journal.sequence(:title) {|n| "Ants#{n}"}
end

Factory.define :author_participation do |row|
  row.association :author
  row.association :reference
end
