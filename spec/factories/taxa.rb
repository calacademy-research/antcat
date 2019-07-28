FactoryBot.define do
  factory :taxon do
    transient do
      name_string {}
    end

    before(:create) do |taxon, evaluator|
      if evaluator.name_string
        taxon.name.name = evaluator.name_string
      end
    end

    protonym
    valid

    factory :family, class: Family do
      association :name, factory: :family_name
    end

    factory :subfamily, class: Subfamily do
      association :name, factory: :subfamily_name
    end

    factory :tribe, class: Tribe do
      association :name, factory: :tribe_name
      subfamily
    end

    factory :subtribe, class: Subtribe do
      association :name, factory: :subtribe_name
      tribe
      subfamily { |a| a.tribe.subfamily }
    end

    factory :genus, class: Genus do
      association :name, factory: :genus_name
      tribe
      subfamily { |a| a.tribe && a.tribe.subfamily }
    end

    factory :subgenus, class: Subgenus do
      association :name, factory: :subgenus_name
      genus
    end

    factory :species, class: Species do
      association :name, factory: :species_name
      genus
    end

    factory :subspecies, class: Subspecies do
      association :name, factory: :subspecies_name
      species
      genus
    end

    trait :valid do
      status { Status::VALID }
    end

    trait :synonym do
      status { Status::SYNONYM }
      with_current_valid_taxon
    end

    trait :homonym do
      status { Status::HOMONYM }
    end

    trait :original_combination do
      status { Status::ORIGINAL_COMBINATION }
      with_current_valid_taxon
    end

    trait :unidentifiable do
      status { Status::UNIDENTIFIABLE }
    end

    trait :unavailable do
      status { Status::UNAVAILABLE }
    end

    trait :excluded_from_formicidae do
      status { Status::EXCLUDED_FROM_FORMICIDAE }
    end

    trait :unavailable_misspelling do
      status { Status::UNAVAILABLE_MISSPELLING }
    end

    trait :unavailable_uncategorized do
      status { Status::UNAVAILABLE_UNCATEGORIZED }
    end

    trait :fossil do
      fossil { true }
    end

    trait :with_current_valid_taxon do
      current_valid_taxon { Family.first || FactoryBot.create(:family) }
    end

    trait :old do
      association :taxon_state, review_state: TaxonState::OLD
    end

    trait :waiting do
      association :taxon_state, review_state: TaxonState::WAITING
    end

    trait :approved do
      association :taxon_state, review_state: TaxonState::APPROVED
    end

    trait :with_history_item do
      after :create do |taxon|
        create :taxon_history_item, taxon: taxon
      end
    end
  end
end
