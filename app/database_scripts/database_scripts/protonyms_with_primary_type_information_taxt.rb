# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithPrimaryTypeInformationTaxt < DatabaseScript
    PER_PAGE = 500

    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      Protonym.where.not(primary_type_information_taxt: nil).includes(:name, :authorship)
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'Protonym', 'primary_type_information_taxt'
        t.rows(results_to_render) do |protonym|
          [
            protonym_link(protonym),
            ::Types::FormatTypeField[protonym.primary_type_information_taxt]
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms with <code>primary_type_information_taxt</code>

section: research
tags: [protonyms, types, inline-taxt, list]

description: >

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithPrimaryTypeInformationTaxt
  - ProtonymsWithSecondaryTypeInformationTaxt
  - ProtonymsWithTypeNotesTaxt
