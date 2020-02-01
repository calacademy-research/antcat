module DatabaseScripts
  class OnlineEarlyReferences < DatabaseScript
    def results
      Reference.where(online_early: true)
    end

    def render
      as_table do |t|
        t.header :id, :reference, :what_links_here
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
tags: [list]

description: >
  Pages, date, PDF may need to be updated after print publication.


  Priority in taxonomy is based on the print version date not online early.

related_scripts:
  - MissingReferences
  - OnlineEarlyReferences
  - UnknownReferences
