#<span
#   class="Z3988"
#   title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Focoins.info%3Agenerator&amp;rft.genre=article&amp;rft.atitle=Records+of+insect+collection+%28Part+I%29+in+the+Natural+History+Research+Centre%2C+Baghdad&amp;rft.title=Bull.+Nat.+Hist.+Res.+Cent.+Univ.+Baghdad&amp;rft.stitle=Bull+Nat+Hist+Res+Cent+Univ+Baghdad">
#      (Insert Default Text Here)
#</span>

class Views::References::Show < Views::Base
  def container_content
    p do
      b "Authors "
      text @reference.authors
    end

    p do
      b "Title "
      text @reference.title
    end

    p do
      b "Citation "
      text @reference.citation
    end

    p do
      b "Year "
      text @reference.year
    end

    p do
      b "Notes "
      text @reference.notes
    end

    p do
      b "Possess "
      text @reference.possess
    end

    p do
      b "Date "
      text @reference.date
    end

    p do
      b "Cite code "
      text @reference.cite_code
    end

    p do
      b "Created "
      text @reference.created_at
    end

    p do
      b "Updated "
      text @reference.updated_at
    end

    p do
      link_to 'Edit', edit_reference_path(@reference)
      rawtext ' | '
      link_to "Delete ", @reference, :confirm => 'Are you sure?', :method => :delete
      rawtext ' | '
      link_to "View All", references_path
    end
  end

end
