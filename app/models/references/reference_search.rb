# TODO extract into a new class instead of reopening the main class.

class Reference < ApplicationRecord
  searchable do
    string  :type
    integer :year
    text    :author_names_string
    text    :citation_year
    text    :title
    text    :journal_name do journal.name if journal end
    text    :publisher_name do publisher.name if publisher end
    text    :year_as_string do year.to_s if year end # quick fix to make the year searchable as a keyword
    text    :citation
    text    :editor_notes
    text    :public_notes
    text    :taxonomic_notes
    string  :citation_year
    string  :author_names_string
    # Tried adding DOI here, we get "NoMethodError: undefined method `doi' for #<MissingReference:0x007fc4abfce460> "
    # Missing references shouldn't have a DOI, I would think.
    # TODO: Test searching for doi, see if that works?
  end

  def self.list_all_references_for_endnote
    joins(:author_names)
      .includes(:journal, :author_names, :document, [{publisher: :place}])
      .where.not(type: 'MissingReference').all
  end
end
