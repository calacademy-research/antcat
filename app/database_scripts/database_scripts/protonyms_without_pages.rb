module DatabaseScripts
  class ProtonymsWithoutPages < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Protonym.joins(:authorship).where(citations: { pages: [nil, ''] })
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
  Protonyms with authorships (table `citations`) that have no pages.
tags: [new!]
topic_areas: [protonyms]
