FactoryBot.define do
  factory :wiki_page do
    sequence(:title) { |n| "Help page no. #{n}" }
    sequence(:content, 'a') { |n| "Content is: #{n}" }
  end
end
