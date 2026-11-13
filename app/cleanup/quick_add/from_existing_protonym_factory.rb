# frozen_string_literal: true

# Quick add (an editors' shortcut on database script pages): picks the quick adder for an existing protonym by its
# rank (species or subspecies); other ranks get a "not supported" adder.
module QuickAdd
  class FromExistingProtonymFactory
    def self.create_quick_adder protonym
      case protonym_rank(protonym)
      when Rank::SPECIES
        QuickAdd::FromExistingSpeciesProtonym.new(protonym)
      when Rank::SUBSPECIES
        QuickAdd::FromExistingSubspeciesProtonym.new(protonym)
      when Rank::INFRASUBSPECIES
        QuickAdd::QuickAddNotSupported.new("Infrasubspecies protonyms are not supported")
      else
        QuickAdd::QuickAddNotSupported.new("Not supported")
      end
    end

    def self.protonym_rank protonym
      case protonym.name.cleaned_name.split.size
      when 2 then Rank::SPECIES
      when 3 then Rank::SUBSPECIES
      when 4 then Rank::INFRASUBSPECIES
      end
    end
  end
end
