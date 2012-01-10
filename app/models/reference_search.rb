# coding: UTF-8
class Reference < ActiveRecord::Base
  class BoltonReferenceNotMatched < StandardError; end
  class BoltonReferenceNotFound < StandardError; end

  searchable do
    integer :year
    text    :author_names_string
    text    :title
    text    :journal_name do journal.name if journal end
    text    :publisher_name do publisher.name if publisher end
    text    :citation
    text    :cite_code
    text    :editor_notes
    text    :public_notes
    text    :taxonomic_notes
    string  :citation_year
    string  :author_names_string
  end

  def self.perform_search options = {}
    case
    when options[:fulltext]
      start_year, end_year = options[:start_year], options[:end_year]
      page = options[:page]
      search {
        keywords options[:fulltext]
        if start_year
          if end_year
            with(:year).between(start_year..end_year)
          else
            with(:year).equal_to start_year
          end
        end
        paginate(:page => options[:page]) if options[:page]
        order_by :author_names_string
        order_by :citation_year
      }.results

    when options[:authors]
      authors = options[:authors]
      select('`references`.*').
         joins(:author_names)
        .joins('JOIN authors ON authors.id = author_names.author_id')
        .where('authors.id IN (?)', authors)
        .group('references.id')
        .having("COUNT(`references`.id) = #{authors.length}")
        .order(:author_names_string_cache, :citation_year)

    when options[:id]
      where(:id => options[:id])

    else
      if options[:order]
        query = order "#{options[:order]} DESC"
      else
        query = order 'author_names_string_cache, citation_year'
      end
      query = query.paginate :page => options[:page] if options[:page]
      query
    end
  end

  def self.do_search options = {}
    return perform_search if options.empty?
    return perform_search(:order => :updated_at, :page => options[:page]) if options[:review]
    return perform_search(:order => :created_at, :page => options[:page]) if options[:whats_new]

    if options[:authors]
      author_names = AuthorParser.parse(options[:authors])[:names]
      authors = Author.find_by_names author_names
      return perform_search :authors => authors, :page => options[:page]
    end

    fulltext_string = options[:q] || ''

    if match = fulltext_string.match(/\d{5,}/)
      return perform_search :id => match[0].to_i
    end

    start_year, end_year = parse_and_extract_years fulltext_string

    return perform_search :fulltext => fulltext_string, :start_year => start_year, :end_year => end_year, :page => options[:page]

    #string = ActiveSupport::Inflector.transliterate options[:q].downcase

    #only_show_unknown_references = false
    #question_mark_index = string.index '?'
    #if question_mark_index
      #string[question_mark_index] = ''
      #only_show_unknown_references = true
    #end

    #results = search_solr string, options, only_show_unknown_references, paginate

    #if only_show_unknown_references
      #ids = results.map &:id
      #return where(:type => 'UnknownReference').where('id' => ids).paginate(:page => options[:page])
    #end

    #results
  end

  def self.parse_and_extract_years string
    start_year = end_year = nil
    if match = string.match(/\b(\d{4})-(\d{4}\b)/)
      start_year = match[1].to_i
      end_year = match[2].to_i
    elsif match = string.match(/(?:^|\s)(\d{4})\b/)
      start_year = match[1].to_i
    end

    return nil, nil unless (1758..(Time.now.year + 1)).include? start_year

    string.gsub! /#{match[0]}/, '' if match
    return start_year, end_year
  end

end
