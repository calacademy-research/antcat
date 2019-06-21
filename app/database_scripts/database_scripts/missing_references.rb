module DatabaseScripts
  class MissingReferences < DatabaseScript
    def results
      MissingReference.order(:citation)
    end

    def render
      as_table do |t|
        t.header :id, :reference, :what_link_here, :replace
        t.rows do |reference|
          [
            link_to(reference.id, reference_path(reference)),
            markdown_reference_link(reference),
            link_to("What Links Here", reference_what_links_here_path(reference), class: "btn-normal btn-tiny"),
            link_to('Replace', replace_missing_path(reference), class: 'btn-normal btn-tiny')
          ]
        end
      end
    end
  end
end

__END__

topic_areas: [references]
