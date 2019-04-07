FactoryBot.define do
  factory :name do
    epithet { name }

    factory :family_name, class: FamilyName do
      name { 'Formicidae' }
    end

    factory :subfamily_name, class: SubfamilyName do
      sequence(:name) { |n| "Subfamily#{n}" }
    end

    factory :tribe_name, class: TribeName do
      sequence(:name) { |n| "Tribe#{n}" }
    end

    factory :genus_name, class: GenusName do
      sequence(:name) { |n| "Genus#{n}" }
    end

    factory :subgenus_name, class: SubgenusName do
      sequence(:name) { |n| "Atta (Subgenus#{n})" }
      epithet { name.split.last.remove('(', ')') }
    end

    factory :species_name, class: SpeciesName do
      sequence(:name) { |n| "Atta species#{n}" }
      epithet { name.split.last }
    end

    factory :subspecies_name, class: SubspeciesName do
      sequence(:name) { |n| "Atta species subspecies#{n}" }
      epithet { name.split.last }
      epithets { name.split[-2..-1].join(' ') }
    end
  end
end
