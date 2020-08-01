# frozen_string_literal: true

module DatabaseScripts
  class ReferenceSectionTaxts < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def statistics
      <<~HTML.html_safe
        Reference sections in database: #{ReferenceSection.count}<br>
        <br>
        List #1 - Blank references_taxt results: #{blank_references_taxt.count}<br>
        List #2 - Blank title_taxt results: #{blank_title_taxt.count}<br>
        List #3 - Non-blank subtitle_taxt results: #{non_blank_subtitle_taxt.count}<br>
        List #4 - Non-blank title_taxt results: #{non_blank_title_taxt.count}<br>
      HTML
    end

    def blank_references_taxt
      ReferenceSection.where(references_taxt: nil).includes(:taxon)
    end

    def blank_title_taxt
      ReferenceSection.where(title_taxt: nil).includes(:taxon)
    end

    def non_blank_subtitle_taxt
      ReferenceSection.where.not(subtitle_taxt: nil).includes(:taxon)
    end

    def non_blank_title_taxt
      ReferenceSection.where.not(title_taxt: nil).includes(:taxon)
    end

    def render
      as_table do |t|
        t.caption "List #1 - Blank references_taxt"
        t.header(*table_columns)

        t.rows(blank_references_taxt) do |reference_section|
          format_taxts reference_section
        end
      end <<
        as_table do |t|
          t.caption "List #2 - Blank title_taxt"
          t.header(*table_columns)

          t.rows(blank_title_taxt) do |reference_section|
            format_taxts reference_section
          end
        end <<
        as_table do |t|
          t.caption "List #3 - Non-blank subtitle_taxt (all subtitle_taxt)"
          t.header(*table_columns)

          t.rows(non_blank_subtitle_taxt) do |reference_section|
            format_taxts reference_section
          end
        end <<
        as_table do |t|
          t.caption "List #4 - Non-blank title_taxt (all title_taxt)"
          t.header(*table_columns)

          t.rows(non_blank_title_taxt) do |reference_section|
            [
              link_to(reference_section.id, reference_section_path(reference_section)),
              taxon_link(reference_section.taxon_id),
              reference_section.taxon.type,
              (reference_section.references_taxt ? not_blank : blank_warning),
              reference_section.title_taxt || blank,
              (reference_section.subtitle_taxt ? not_blank_warning : blank)
            ]
          end
        end
    end

    private

      def table_columns
        ['ID', 'Taxon', 'Taxon rank', 'references_taxt', 'title_taxt', 'subtitle_taxt']
      end

      def format_taxts reference_section
        [
          link_to(reference_section.id, reference_section_path(reference_section)),
          taxon_link(reference_section.taxon_id),
          reference_section.taxon.type,
          reference_section.references_taxt&.truncate(50, omission: '... [truncated]') || blank,
          reference_section.title_taxt || blank,
          reference_section.subtitle_taxt || blank
        ]
      end

      def blank
        '<small class="gray-text">[blank]</small>'.html_safe
      end

      def blank_warning
        '<small class="bold-warning gray-text">[blank]</small>'.html_safe
      end

      def not_blank
        '<small class="gray-text">[not blank]</small>'.html_safe
      end

      def not_blank_warning
        '<small class="bold-warning gray-text">[not blank]</small>'.html_safe
      end
  end
end

__END__

section: research
category: Taxt
tags: [list]

description: >
  Script added to investigate how we can improve reference sections.

related_scripts:
  - NonStandardReferenceSections
  - ReferenceSectionTaxts
