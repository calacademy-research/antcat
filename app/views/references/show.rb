class Views::References::Show < Views::Base
  def container_content

    widget Views::Coins.new :reference => @reference

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
      b "Public notes "
      text @reference.public_notes
    end

    p do
      b "Private notes "
      text @reference.private_notes
    end

    p do
      b "Taxonomic notes "
      text @reference.taxonomic_notes
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
