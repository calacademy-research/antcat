require 'factory_girl'

Factory.define :ward_reference do |ward_reference|
  ward_reference.authors  'Fisher'
  ward_reference.title  'Ants'
  ward_reference.citation  'New York: Wiley. 23pp.'
end

def ward_reference_factory attributes
  attributes.reverse_merge!(:authors => 'Fisher', :title => 'Ants', :year => '2010a')
  WardReference.new(attributes).export
end

Factory.define :reference do |reference|
  reference.citation_year   "2010"
  reference.title           "Ants are my life"
end

def reference_factory attributes = {}
  author = attributes.delete(:author)
  reference = Factory(:reference, attributes)
  reference.authors << Factory(:author, :name => author)
  reference
end

Factory.define :article_reference do |reference|
  reference.title               "Ants are my life"
  reference.citation_year       '2010d'
  reference.series_volume_issue '1'
  reference.pagination          '22'
end

Factory.define :book_reference do |reference|
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

Factory.define :publisher do |row|
  row.name  'Wiley'
  row.place 'New York'
end
