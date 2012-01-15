# coding: UTF-8
class Reference < ActiveRecord::Base
  class BoltonReferenceNotMatched < StandardError; end
  class BoltonReferenceNotFound < StandardError; end

  searchable do
    string  :type
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
    page = options[:page]
    case
    when options[:fulltext]
      start_year, end_year = options[:start_year], options[:end_year]
      search {
        keywords options[:fulltext]

        if start_year
          if end_year
            with(:year).between(start_year..end_year)
          else
            with(:year).equal_to start_year
          end
        end

        case options[:filter]
        when :unknown_references_only
          with :type, 'UnknownReference'
        when :no_missing_references
          without :type, 'MissingReference'
        end

        paginate page: page if page

        order_by :author_names_string
        order_by :citation_year
      }.results

    when options[:authors]
      authors = options[:authors]
      query = select('`references`.*').
         joins(:author_names)
        .joins('JOIN authors ON authors.id = author_names.author_id')
        .where('authors.id IN (?)', authors)
        .group('references.id')
        .having("COUNT(`references`.id) = #{authors.length}")
        .order(:author_names_string_cache, :citation_year)

        case options[:filter]
        when :unknown_references_only
          with :type, 'UnknownReference'
        when :no_missing_references
          without :type, 'MissingReference'
        end
      query = query.paginate page: page if page
      query 

    when options[:id]
      query = where id: options[:id]
      query = query.paginate page: page
      query

    else
      if options[:order]
        query = order "#{options[:order]} DESC"
      else
        query = order 'author_names_string_cache, citation_year'
      end
      query = query.paginate page: page if page
      query
      case options[:filter]
      when :unknown_references_only
        query = query.where 'type == "UnknownReference"'
      when :no_missing_references, nil
        query = query.where 'type != "MissingReference" OR type IS NULL'
      end
      query
    end
  end

  def self.do_search options = {}

    search_options = {}
    if options[:format] != :endnote_import
      search_options[:page] = options[:page] || 1
    end

    case
    when options[:whats_new]
      search_options.merge! order: :created_at

    when options[:review]
      search_options.merge! order: :updated_at

    when options[:authors]
      author_names = AuthorParser.parse(options[:authors])[:names]
      authors = Author.find_by_names author_names
      search_options.merge! authors: authors

    when options.key?(:q)
      fulltext_string = options[:q].dup || ''

      if match = fulltext_string.match(/\d{5,}/)
        return perform_search id: match[0].to_i
      end

      start_year, end_year = parse_and_extract_years fulltext_string
      filter = parse_and_extract_filter fulltext_string
      fulltext_string = ActiveSupport::Inflector.transliterate fulltext_string.downcase

      search_options[:fulltext] = fulltext_string if fulltext_string
      search_options[:start_year] = start_year if start_year
      search_options[:end_year] = end_year if end_year
      search_options[:filter] = filter if filter

    end

    perform_search search_options

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

  def self.parse_and_extract_filter string
    question_mark_index = string.index '?'
    if question_mark_index
      string[question_mark_index] = ''
      string.strip!
      return :unknown_references_only
    end
  end

  def self.find_by_bolton_key data
    year = data[:year] || data[:in][:year]
    bolton_key = Bolton::ReferenceKey.new(data[:author_names].join(' '), year).to_s :db

    reference = find_by_bolton_key_cache bolton_key
    return reference if reference

    bolton_reference = Bolton::Reference.find_by_key_cache bolton_key
    if !bolton_reference
      reference = MissingReference.import 'no Bolton', data
    else
      reference = bolton_reference.match || MissingReference.import('no Bolton match', data)
    end

    reference.update_attribute :bolton_key_cache, bolton_key

    reference
  end

end
