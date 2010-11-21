require 'factory_girl'

Factory.define :ward_reference do |ward_reference|
  ward_reference.authors  'Fisher, B.L.'
  ward_reference.title  'Ants'
  ward_reference.citation  'New York: Wiley. 23pp.'
end

def ward_reference_factory attributes
  attributes.reverse_merge!(:authors => 'Fisher, B.L.', :title => 'Ants', :year => '2010a')
  WardReference.new(attributes).export
end

Factory.define :author_name do |author_name|
  author_name.sequence(:name) {|n| "Fisher#{n}, B.L."}
end

Factory.define :publisher do |row|
  row.name  'Wiley'
  row.association :place
end

Factory.define :place do |row|
  row.name  'New York'
end

Factory.define :reference do |reference|
  reference.author_names     {[Factory(:author_name)]}
  reference.title           "Ants are my life"
  reference.citation_year   "2010"
end

Factory.define :article_reference do |reference|
  reference.author_names        {[Factory(:author_name)]}
  reference.title               "Ants are my life"
  reference.citation_year       '2010d'
  reference.association         :journal
  reference.series_volume_issue '1'
  reference.pagination          '22'
end

Factory.define :book_reference do |reference|
  reference.author_names        {[Factory(:author_name)]}
  reference.title               "Ants are my life"
  reference.citation_year       '2010d'
  reference.association         :publisher
  reference.pagination          '22 pp.'
end

Factory.define :unknown_reference do |reference|
  reference.author_names        {[Factory(:author_name)]}
  reference.title               "Ants are my life"
  reference.citation_year       '2010d'
  reference.citation            'New York'
end

Factory.define :nested_reference do |reference|
  reference.author_names        {[Factory(:author_name)]}
  reference.title               "Ants are my life"
  reference.citation_year       '2010d'
  reference.pages_in            'In: '
  reference.nested_reference    {Factory :book_reference}
end

def reference_factory attributes = {}
  author_name = Factory(:author_name, :name => attributes.delete(:author_name))
  reference = Factory(:reference, attributes.merge(:author_names => [author_name]))
  reference
end

Factory.define :journal do |journal|
  journal.sequence(:name) {|n| "Ants#{n}"}
end

Factory.define :author_participation do |row|
  row.association :author_name
  row.association :reference
end

Factory.define :user do |user|
  user.email     'mark@example.com'
  user.password  'secret'
end
