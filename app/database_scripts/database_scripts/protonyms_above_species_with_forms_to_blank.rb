# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsAboveSpeciesWithFormsToBlank < DatabaseScript
    def results
      Protonym.joins(:name).where.not(names: { type: Name::SPECIES_GROUP_NAMES }).where.not(forms: nil)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Forms'
        t.rows do |protonym|
          [
            protonym_link(protonym),
            protonym.forms
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms above species with forms to blank

section: pa-action-required
category: Catalog
tags: [new!]

issue_description:

description: >
  To be blanked by script.

related_scripts:
  - ProtonymsAboveSpeciesWithFormsToBlank
