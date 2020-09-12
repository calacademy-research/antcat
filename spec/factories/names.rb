# frozen_string_literal: true

FactoryBot.define do
  factory :name do
    factory :family_name, class: 'FamilyName' do
      sequence(:name, 'a') { |n| "Family#{n}idae" }
    end

    factory :subfamily_name, class: 'SubfamilyName' do
      sequence(:name, 'a') { |n| "Subfamily#{n}inae" }
    end

    factory :tribe_name, class: 'TribeName' do
      sequence(:name, 'a') { |n| "Tribe#{n}ii" }
    end

    factory :subtribe_name, class: 'SubtribeName' do
      sequence(:name, 'a') { |n| "Subtribe#{n}ina" }
    end

    factory :genus_name, class: 'GenusName' do
      sequence(:name, 'a') { |n| "Genus#{n}ia" }
    end

    factory :subgenus_name, class: 'SubgenusName' do
      sequence(:name, 'a') { |n| "Atta (Subgenus#{n})" }
    end

    factory :species_name, class: 'SpeciesName' do
      sequence(:name, 'a') { |n| "Atta species#{n}" }
    end

    factory :subspecies_name, class: 'SubspeciesName' do
      sequence(:name, 'a') { |n| "Atta species subspecies#{n}" }
    end

    factory :infrasubspecies_name, class: 'InfrasubspeciesName' do
      sequence(:name, 'a') { |n| "Atta species subspecies#{n} infrasubspecies" }
    end

    trait :non_conforming do
      non_conforming { true }
    end
  end
end
