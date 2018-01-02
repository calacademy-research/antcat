FactoryBot.define do
  factory :site_notice do
    title "Site notice title"
    message "Site notice message"
    association :user, factory: :user
  end
end
