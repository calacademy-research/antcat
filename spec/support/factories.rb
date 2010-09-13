require 'factory_girl'

def ward_reference_factory attributes
  attributes.reverse_merge!(:authors => 'Fisher', :title => 'Ants')
  WardBibliography.new.import_reference attributes
end

Factory.define :reference do |reference|
  reference.citation_year    "2010"
  reference.title   "Ants are my life"
  reference.year  2010
end

def reference_factory attributes = {}
  author = attributes.delete(:author)
  reference = Factory(:reference, attributes)
  reference.authors << Factory(:author, :name => author)
  reference
end

Factory.define :article_reference do |reference|
  reference.title   "Ants are my life"
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
