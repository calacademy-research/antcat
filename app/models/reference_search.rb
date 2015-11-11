# coding: UTF-8
class Reference < ActiveRecord::Base
  class BoltonReferenceNotMatched < StandardError; end
  class BoltonReferenceNotFound < StandardError; end

  searchable do
    string  :type
    integer :year
    text    :author_names_string
    text    :citation_year
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
    # Tried adding DOI here, we get "NoMethodError: undefined method `doi' for #<MissingReference:0x007fc4abfce460> "
    # Missing references shouldn't have a DOI, I would think.
    # TODO: Test searching for doi, see if that works?
  end

  def self.search &block
     Sunspot.search Reference, &block
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
        when :nested_references_only
          with :type, 'NestedReference'
        when :no_missing_references
          without :type, 'MissingReference'
        end

        if page
          paginate page: page
        else
          paginate page: 1, per_page: 9999999
        end

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
      when :nested_references_only
        query = query.where 'type == "NestedReference"'
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

    search_options[:filter] = :no_missing_references

    case
    when options[:whats_new]
      search_options.merge! order: :created_at

    when options[:review]
      search_options.merge! order: :updated_at

    when options[:is_author_search]
      # This is minimally useful; it only returns when we get an exact
      # author match.
      # TODO: rewrite to do a fuzzy search if there are no hits on "author"?
      author_names = Parsers::AuthorParser.parse(options[:q])[:names]
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
    hash_index = string.index '#'
    if hash_index
      string[hash_index] = ''
      string.strip!
      return :nested_references_only
    end
  end

  def self.get_author_names_and_year data
    year = data[:year] || data[:in] && data[:in][:year]
    author_names = data[:in] && data[:in][:author_names] || data[:author_names]
    return author_names, year
  end

  def self.find_by_bolton_key data
    author_names, year = get_author_names_and_year data

    return MissingReference.import 'no year', data unless year

    bolton_key = Bolton::ReferenceKey.new(author_names.join(' '), year).to_s :db

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

  def self.find_bolton bolton_reference
    bolton_key = bolton_reference.key.to_s :db

    reference = find_by_bolton_key_cache bolton_key
    return reference if reference

    bolton_reference = Bolton::Reference.find_by_key_cache bolton_key
    if !bolton_reference
      reference = nil
    else
      reference = bolton_reference.match
    end

    reference.update_attribute :bolton_key_cache, bolton_key if reference

    reference
  end

end
