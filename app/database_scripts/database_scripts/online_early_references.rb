# frozen_string_literal: true

module DatabaseScripts
  class OnlineEarlyReferences < DatabaseScript
    def results
      Reference.where(online_early: true)
    end

    def render
      as_table do |t|
        t.header 'Reference', 'What Links Here'
        t.rows do |reference|
          [
            reference_link(reference),
            link_to('What Links Here', reference_what_links_here_path(reference), class: 'btn-default')
          ]
        end
      end
    end
  end
end

__END__

section: list
tags: [references]

description: >
  Pages, date, PDF may need to be updated after print publication.


  Priority in taxonomy is based on the print version date not online early.

related_scripts:
  - OnlineEarlyReferences
