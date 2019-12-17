module DatabaseScripts
  class MissingReferences < DatabaseScript
    def results
      MissingReference.order(:citation)
    end

    def render
      as_table do |t|
        t.header :id, :reference, :what_links_here, :replace
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

category: References

description: >
  "Missing references" is a type of incomplete reference where only the author's last name and/or year is known.
  We want to replace them with proper references.


  **How to fix**

  Use the 'What Links Here' button too see where a missing reference is being used.


  Once you know which reference it should be replaced with, use the 'Replace' button to replace all occurrences with a different reference.


  If no replacement reference exits, you can [add a new reference to AntCat](/references/new).


  To replace a single occurence, use the 'What Links Here' button, navigate to the item, and edit it.

related_scripts:
  - MissingReferences
  - UnknownReferences
