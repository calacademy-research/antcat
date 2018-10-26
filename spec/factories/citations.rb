FactoryBot.define do
  factory :citation do
    reference factory: :article_reference
    pages { '49' }
  end
end
