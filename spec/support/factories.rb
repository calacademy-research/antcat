require 'factory_girl'

Factory.define :ward_reference do |reference|
  reference.authors "Fisher, B.L."
  reference.year    "2010"
  reference.title   "Ants are my life"
  reference.sequence(:citation) {|n| "Informatica 21:#{n}"}
end

Factory.define :reference do |reference|
end

Factory.define :author do |author|
  author.sequence(:name) {|n| "Fisher#{n}, B.L."}
end

Factory.define :source do |source|
  source.year  2010
  source.after_build do |article|
    source.authors << Factory(:author)
  end
end

Factory.define :article, :parent => :source do |article|
  article.association(:issue)
end

Factory.define :issue do |issue|
  issue.sequence(:volume) {|n| n}
  issue.association(:journal)
end

Factory.define :journal do |journal|
  journal.sequence(:title) {|n| "Ants#{n}"}
end

Factory.define :article_reference do |reference|
  reference.association :source, :factory => :article
end

Factory.define :author_participation do |row|
  row.association :author
  row.association :source
end
