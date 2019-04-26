module DatabaseScripts
  class MissingReferences < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      MissingReference.order(:citation)
    end

    def render
      as_table do |t|
        t.header :id, :reference, :what_link_here
        t.rows do |reference|
          [
            link_to(reference.id, reference_path(reference)),
            markdown_reference_link(reference),
            link_to("What Links Here", reference_what_links_here_index_path(reference), class: "btn-normal btn-tiny")
          ]
        end
      end
    end
  end
end

__END__

tags: [new!]
topic_areas: [references]
