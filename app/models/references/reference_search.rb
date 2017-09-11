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

  def self.do_search options = {}
    options[:page] ||= 1
    search_query = if options[:q].present? then options[:q].dup else "" end

    keyword_params = extract_keyword_params search_query
    options.merge! keyword_params

    fulltext_search options
  end

  def self.author_search author_names_query, page = nil
    References::AuthorSearch.new(author_names_query, page).call
  end

  def self.extract_keyword_params keyword_string
    References::ExtractKeywordParams.new(keyword_string).call
  end

  def self.list_all_references_for_endnote
    joins(:author_names)
      .includes(:journal, :author_names, :document, [{publisher: :place}])
      .where.not(type: 'MissingReference').all
  end

  def self.fulltext_search options = {}
    References::FulltextSearch.new(options).call
  end
end
