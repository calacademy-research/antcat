# frozen_string_literal: true

module DatabaseScripts
  class NonStandardReferenceSections < DatabaseScript
    def results
      non_standard = []

      ReferenceSection.find_each do |reference_section|
        next unless reference_section.references_taxt

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
            reference_section_link(reference_section.id),
            markdown_taxon_link(reference_section.taxon),
            content,
            issue
          ]
        end
      end
    end

    private

      def reference_section_link id
        "<a href='/reference_sections/#{id}/edit'>#{id}</a>"
      end
  end
end

__END__

title: Non-standard reference sections
category: Taxt

description: See %github452 for why we want this.

related_scripts:
  - NonStandardReferenceSections
  - ReferenceSectionTaxts
