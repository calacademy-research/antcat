FactoryGirl.define do
  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end
end

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end
