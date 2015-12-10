# coding: UTF-8
class Reference < ActiveRecord::Base

  searchable do
    string  :type
    integer :year
    text    :author_names_string
    text    :citation_year
    text    :title
    text    :journal_name do journal.name if journal end
    text    :publisher_name do publisher.name if publisher end
    text    :year_as_string  do year.to_s if year end # quick fix to make the year searchable as a keyword
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

  def self.search &block
    Sunspot.search Reference, &block
  end

  def self.do_search options = {}
    options[:page] ||= 1
    search_query = if options[:q].present? then options[:q].dup else "" end

    keyword_params = extract_keyword_params search_query
    options.merge! keyword_params

    fulltext_search options
  end

  private
    def self.extract_keyword_params keyword_string
      keywords_params = {}
      regexes = [                                                          # order matters
        ["year",   '(?<start_year>\d{4})-(?<end_year>\d{4})'],             # year:2003-2015
        ["year",   '(\d{4})'],                                             # year:2003
        ["type",   '(?<reference_type>nested|unknown|nomissing|missing)'], # type:nested
        ["author", '"(.*?)"'],                                             # author:"Barry Bolton"
        ["author", '\'(.*?)\''],                                           # author:'Barry Bolton'
        ["author", '(\w+)']                                                # author:Bolton
      ]

      regexes.each do |keyword, regex|
        match = keyword_string.match /#{keyword}:#{regex}/
        next unless match

        unless match.names.empty?
          match.names.each { |param| keywords_params[param.to_sym] = match[param] }
        else
          keywords_params[keyword.to_sym] = $1
        end
        keyword_string.gsub! match.to_s, ""
      end

      if keywords_params[:reference_type].present?
        keywords_params[:reference_type] = keywords_params[:reference_type].to_sym
      end
      keywords_params[:keywords] = keyword_string.squish
      keywords_params
    end

    #TODO split logic into scopes/controller
    def self.list_references options = {}
      reference_type = options[:reference_type] || :nomissing

      query = if options[:order]
                order("#{options[:order]} DESC")
              else
                order('author_names_string_cache, citation_year')
              end

      query = case reference_type
              when :unknown
                query.where('type == "UnknownReference"')
              when :nested
                query.where('type == "NestedReference"')
              when :missing
                query.where('type == "MissingReference"')
              when :nomissing
                query.where('type != "MissingReference" OR type IS NULL')
              end

      page = options[:page] || 1
      query.paginate(page: page)
    end

    def self.list_all_references_for_endnote
      # Not very pretty but this is actually a single SQL query (page takes a couple of seconds load),
      # which is better than making ~50000 queries (takes minutes). TODO refactor into the Sunspot
      # search method after figuring out how to make it ':include' related fields and handle pagination
      joins(:author_names)
        .includes(:journal, :author_names, :document, [{publisher: :place}])
        .where.not(type: 'MissingReference').all
    end

    def self.fulltext_search options = {}
      page            = options[:page] || 1
      items_per_page  = options[:items_per_page] || 30
      year            = options[:year]
      start_year      = options[:start_year]
      end_year        = options[:end_year]
      author          = options[:author]
      search_keywords = options[:keywords] || ""

      substrings_to_remove = ['<i>', '</i>', '\*'] # TODO move to solr conf?
      substrings_to_remove.each { |substring| search_keywords.gsub! /#{substring}/, '' }
      search_keywords.gsub! /-|:/, ' ' # TODO fix in solr

      search {
        keywords search_keywords

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
        when :unknown
          with :type, 'UnknownReference'
        when :nested
          with :type, 'NestedReference'
        when :missing
          with :type, 'MissingReference'
        when :nomissing
          without :type, 'MissingReference'
        else
          without :type, 'MissingReference'
        end

        if options[:endnote_export]
          paginate page: 1, per_page: 9999999 #hehhehe
        elsif page
          paginate page: page, per_page: items_per_page
        end

        order_by :author_names_string
        order_by :citation_year
      }.results
    end
end