module DatabaseScripts
  class ProtonymsWithSameNameAndReference < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      grouped = Protonym.
        joins(:name, authorship: :reference).
        group('names.name, references.id').
        having("COUNT(protonyms.id) > 1")

      Protonym.joins(:name, authorship: :reference).
        where(
          names: { name: grouped.select('names.name') },
          citations: { reference_id: grouped.select('references.id') }
        ).includes(:name).order('names.name')
    end

    def render
      as_table do |t|
        t.header :id, :protonym
        t.rows do |protonym|
          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym))
          ]
        end
      end
    end
  end
end

__END__
description: >
  Protonym records with the same name (name value) and reference (reference ID).
tags: [new!]
topic_areas: [catalog]
