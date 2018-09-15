FactoryBot.define do
  factory :name do
    sequence(:name) { |_n| raise }
    name_html { name }
    epithet { name }
    epithet_html { name_html }

    factory :family_name, class: FamilyName do
      name 'Formicidae'
    end

    factory :subfamily_name, class: SubfamilyName do
      sequence(:name) { |n| "Subfamily#{n}" }
    end

    factory :tribe_name, class: TribeName do
      sequence(:name) { |n| "Tribe#{n}" }
    end

    factory :subtribe_name, class: SubtribeName do
      sequence(:name) { |n| "Subtribe#{n}" }
    end

    factory :genus_name, class: GenusName do
      sequence(:name) { |n| "Genus#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet_html { "<i>#{name}</i>" }
    end

    factory :subgenus_name, class: SubgenusName do
      sequence(:name) { |n| "Atta (Subgenus#{n})" }
      name_html { "<i>Atta</i> <i>(#{epithet})</i>" }
      epithet { name.split(' ').last.remove('(', ')') }
      epithet_html { "<i>#{epithet}</i>" }
    end

    factory :species_name, class: SpeciesName do
      sequence(:name) { |n| "Atta species#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet { name.split(' ').last }
      epithet_html { "<i>#{epithet}</i>" }
    end

    factory :subspecies_name, class: SubspeciesName do
      sequence(:name) { |n| "Atta species subspecies#{n}" }
      name_html { "<i>#{name}</i>" }
      epithet { name.split(' ').last }
      epithets { name.split(' ')[-2..-1].join(' ') }
      epithet_html { "<i>#{epithet}</i>" }
    end
  end
end
