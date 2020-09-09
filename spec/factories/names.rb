# frozen_string_literal: true

FactoryBot.define do
  factory :name do
    factory :family_name, class: 'FamilyName' do
      sequence(:name, 'a') { |n| "Family#{n}" }
    end

    factory :subfamily_name, class: 'SubfamilyName' do
      sequence(:name, 'a') { |n| "Subfamily#{n}" }
    end

    factory :tribe_name, class: 'TribeName' do
      sequence(:name, 'a') { |n| "Tribe#{n}" }
    end

    factory :subtribe_name, class: 'SubtribeName' do
      sequence(:name, 'a') { |n| "Subtribe#{n}" }
    end

    factory :genus_name, class: 'GenusName' do
      sequence(:name, 'a') { |n| "Genus#{n}" }
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
  end
end
