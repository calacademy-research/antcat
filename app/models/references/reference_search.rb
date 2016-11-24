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
    text    :cite_code
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
    author_names = Parsers::AuthorParser.parse(author_names_query)[:names]
    authors = Author.find_by_names author_names

    query = select('`references`.*')
      .joins(:author_names)
      .joins('JOIN authors ON authors.id = author_names.author_id')
      .where('authors.id IN (?)', authors)
      .group('references.id')
      .having("COUNT(`references`.id) = #{authors.size}")
      .order(:author_names_string_cache, :citation_year)
    query.paginate page: (page || 1)
  end

  # Accepts a string of keywords (the query) and returns a parsed hash;
  # non-matches are placed in `keywords_params[:keywords]`.
  def self.extract_keyword_params keyword_string
    keywords_params = {}
    # Array of arrays used to compile regexes: [["keyword", "regex_as_string"]].

    # By default, the keyword becomes the key used in `keywords_params`. The regex may
    # contain named groups, which are used when we do not want to use the default key name;
    # this may be necessary in some cases (year must be split in two if the input is a range),
    # or simply if we want to use a different key (`reference_type` is better as key than
    # the ambiguous `type`, but 'type:' is better in the search box).

    # Order matters, because matches are removed from the keyword_string;
    # this makes it easier to match variations of the same keyword without
    # adding too much logic. On the wishlist: a gem to take care of this so that
    # we do not have to re-invent the wheel.
    regexes = [
      ["year",   '(?<start_year>\d{4})-(?<end_year>\d{4})'],             # year:2003-2015
      ["year",   '(\d{4})'],                                             # year:2003
      ["type",   '(?<reference_type>nested|unknown|nomissing|missing)'], # type:nested
      ["title",  '"(.*?)"'],                                             # title:"Iceland"
      ["title",  '\'(.*?)\''],                                           # title:'Iceland'
      ["title",  '([^ ]+)'], # **                                        # title:Iceland
      ["author", '"(.*?)"'],                                             # author:"Barry Bolton"
      ["author", '\'(.*?)\''],                                           # author:'Barry Bolton'
      ["author", '([^ ]+)'] # **                                         # author:Bolton
    ]
    # ** = stops matching at space or end of string

    regexes.each do |keyword, regex|
      match = keyword_string.match /#{keyword}: ?#{regex}/i
      next unless match

      # match.names contains named captured groups.
      if match.names.empty?
        # If there are no named captures, use the 'keyword' as key.
        # Eg 'year:2004' --> keywords_params[:year] = '2004'
        keywords_params[keyword.to_sym] = $1
      else
        # If there are named captures, use them as keys.
        # Eg 'year:2004-2005' -->
        #   keywords_params[:start_year] = '2004'
        #   keywords_params[:end_year] = '2005'
        match.names.each { |param| keywords_params[param.to_sym] = match[param] }
      end
      # Replace matched and continue matching.
      keyword_string.gsub! match.to_s, ""
    end

    # This is kind of a hack, but methods further down the line expect :reference_type
    # to contain a symbol (all the other matches, including 'year', are strings).
    if keywords_params[:reference_type].present?
      keywords_params[:reference_type] = keywords_params[:reference_type].to_sym
    end
    # Remove redundant spaces (artifacts from .gsub!)
    keywords_params[:keywords] = keyword_string.squish
    keywords_params
  end

  #TODO split logic into scopes/controller
  def self.list_references options = {}
    reference_type = options[:reference_type] || :nomissing

    query = if options[:order]
              order(options[:order] => :desc)
            else
              order(:author_names_string_cache, :citation_year)
            end

    query = case reference_type
            when :unknown   then query.where(type: "UnknownReference")
            when :nested    then query.where(type: "NestedReference")
            when :missing   then query.where(type: "MissingReference")
            when :nomissing then query.where.not(type: "MissingReference")
            end

    page = options[:page] || 1
    query.includes(:document).paginate(page: page)
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
