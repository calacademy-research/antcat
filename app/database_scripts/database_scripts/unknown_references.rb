# frozen_string_literal: true

module DatabaseScripts
  class UnknownReferences < DatabaseScript
    def results
      UnknownReference.all
    end

    def render
      as_table do |t|
        t.header 'ID', 'Reference', 'What Links Here'
        t.rows do |reference|
          [
            link_to(reference.id, reference_path(reference)),
            markdown_reference_link(reference),
            link_to('What Links Here', reference_what_links_here_path(reference), class: 'btn-normal btn-tiny')
          ]
        end
      end
    end
  end
end

__END__

category: References
tags: []

description: >

related_scripts:
  - OnlineEarlyReferences
  - UnknownReferences
