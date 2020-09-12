# frozen_string_literal: true

module DatabaseScripts
  class NonStandardReferenceSections < DatabaseScript
    def results
      non_standard = []

      ReferenceSection.where.not(references_taxt: nil).find_each do |reference_section|
        reference_section.references_taxt.split(';').each do |content|
          case content.scan("{ref ").size
          when 0
            non_standard << [reference_section, content, 'no reference']
          when 2..99
            non_standard << [reference_section, content, 'multiple references']
          end
        end
      end

      non_standard
    end

    def render
      as_table do |t|
        t.header 'Reference section', 'Taxon', 'Content', 'Issue'
        t.rows do |reference_section, content, issue|
          [
            link_to(reference_section.id, edit_reference_section_path(reference_section)),
            taxon_link(reference_section.taxon),
            content,
            issue
          ]
        end
      end
    end
  end
end

__END__

title: Non-standard reference sections

section: research
category: Taxt
tags: [list]

description: See %github452 for why we want this.

related_scripts:
  - NonStandardReferenceSections
  - ReferenceSectionTaxts
