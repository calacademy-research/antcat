module DatabaseScripts
  class UnknownReferences < DatabaseScript
    def results
      UnknownReference.all
    end

    def render
      as_table do |t|
        t.header :id, :reference, :what_links_here
        t.rows do |reference|
          [
            link_to(reference.id, reference_path(reference)),
            markdown_reference_link(reference),
            link_to('What Links Here', reference_what_links_here_index_path(reference), class: 'btn-normal btn-tiny')
          ]
        end
      end
    end
  end
end

__END__

description: >
  These are called "Other" in the reference form.

tags: [new!]
topic_areas: [references]
