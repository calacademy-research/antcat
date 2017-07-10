# From `DedupeReferenceSections`.

class DatabaseScripts::Scripts::DuplicatedReferenceSections
  include DatabaseScripts::DatabaseScript

  def results
    duplicated_ids = []

    ReferenceSection.find_each do |reference_section|
      ids = ReferenceSection.where('references_taxt = ? AND position > ?',
        reference_section.references_taxt, reference_section.position).pluck(:id)
      duplicated_ids << ids unless ids.blank?
    end

    ReferenceSection.find(duplicated_ids)
  end

  def render
    as_table do
      header :reference_section, :taxon, :status
      rows do |reference_section|
        taxon = reference_section.taxon
        [
          link_reference_section(reference_section),
          markdown_taxon_link(taxon),
          taxon.status
        ]
      end
    end
  end

  private
    def link_reference_section reference_section
      "<a href='/reference_sections/#{reference_section.id}'>#{reference_section.id}</a>"
    end
end

__END__
description: >
  Based on [this script](https://github.com/calacademy-research/antcat/blob/0b1930a3e161e756e3c785bd32d6e54867cc480c/lib/dedupe_reference_sections.rb),
  which destroys all reference sections listed here.
tags: [regression-test]
topic_areas: [catalog]
