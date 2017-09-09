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

  # Fulltext search, but not all fields. Used by at.js.
  def self.fulltext_search_light search_keywords
    Reference.solr_search do
      keywords search_keywords do
        fields(:title, :author_names_string, :citation_year)
      end

      paginate page: 1, per_page: 10
    end.results
  end

  def self.fulltext_search options = {}
    page            = options[:page] || 1
    items_per_page  = options[:items_per_page] || 30
    year            = options[:year]
    start_year      = options[:start_year]
    end_year        = options[:end_year]
    author          = options[:author]
    title           = options[:title]
    search_keywords = options[:keywords] || ""

    # TODO very ugly to make some queries work. Fix in Solr.
    substrings_to_remove = ['<i>', '</i>', '\*'] # Titles may contain these.
    substrings_to_remove.each { |substring| search_keywords.gsub! /#{substring}/, '' }
    # Hyphens, asterixes and colons makes Solr go bananas.
    search_keywords.gsub! /-|:/, ' '
    title.gsub!(/-|:|\*/, ' ') if title
    author.gsub!(/-|:/, ' ') if author

    # Calling `.solr_search` because `.search` is a Ransack method (bundled by ActiveAdmin).
    Reference.solr_search(include: [:document]) do
      keywords search_keywords

      if title
        keywords title do
          fields(:title)
        end
      end

      if author
        keywords author do
          fields(:author_names_string)
        end
      end

      if year
        with(:year).equal_to year
      end

      if start_year && end_year
        with(:year).between(start_year..end_year)
      end

      case options[:reference_type]
      when :unknown   then with    :type, 'UnknownReference'
      when :nested    then with    :type, 'NestedReference'
      when :missing   then with    :type, 'MissingReference'
      when :nomissing then without :type, 'MissingReference'
      else                 without :type, 'MissingReference'
      end

      if options[:endnote_export]
        paginate page: 1, per_page: 9999999 #hehhehe
      elsif page
        paginate page: page, per_page: items_per_page
      end

      order_by :author_names_string
      order_by :citation_year
    end.results
  end
end
