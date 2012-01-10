# coding: UTF-8
class Reference < ActiveRecord::Base
  class BoltonReferenceNotMatched < StandardError; end
  class BoltonReferenceNotFound < StandardError; end

  searchable do
    integer :year
    string  :citation_year
    text    :author_names_string
    string  :author_names_string
    text    :title
    text    :journal_name do journal.name if journal end
    text    :publisher_name do publisher.name if publisher end
    text    :citation
    text    :cite_code
    text    :editor_notes
    text    :taxonomic_notes
  end

  def self.advanced_search parameters = {}
    author_names = AuthorParser.parse(parameters[:q])[:names]
    authors = Author.find_by_names author_names
    reference_ids = find_having_authors authors
    Reference.where('id IN (?)', reference_ids).order(:author_names_string_cache, :citation_year)
  end

  def self.find_having_authors authors
    Reference.select('`references`.*').
      joins(:author_names).
      joins('JOIN authors ON authors.id = author_names.author_id').
      where('authors.id IN (?)', authors).
      group('references.id').
      having("COUNT(`references`.id) = #{authors.length}")
  end

  def self.do_advanced_search options = {}
    paginate = options[:format] != :endnote_import
    results = advanced_search(options)
    paginate ? results.paginate(:page => options[:page]) : results
  end

  def self.do_search options = {}
    return do_advanced_search(options) if options[:advanced]

    paginate = options[:format] != :endnote_import

    return order('updated_at DESC').paginate :page => options[:page] if options[:review]
    return order('created_at DESC').paginate :page => options[:page] if options[:whats_new]

    unless options[:q].present?
      if paginate
        return order(:author_names_string_cache, :citation_year).paginate :page => options[:page]
      else
        return order :author_names_string_cache, :citation_year
      end
    end

    string = ActiveSupport::Inflector.transliterate options[:q].downcase

    only_show_unknown_references = false
    question_mark_index = string.index '?'
    if question_mark_index
      string[question_mark_index] = ''
      only_show_unknown_references = true
    end

    if match = string.match(/\d{5,}/)
      return where(:id => match[0]).paginate :page => 1
    end

    results = search {
      start_year, end_year = parse_and_extract_years string
      if start_year
        if end_year
          with(:year).between(start_year..end_year)
        else
          with(:year).equal_to start_year
        end
      end
      keywords string
      order_by :author_names_string
      order_by :citation_year
      paginate(:page => options[:page]) if paginate
      paginate(:per_page => 5_000) if only_show_unknown_references
    }.results

    if only_show_unknown_references
      ids = results.map &:id
      return where(:type => 'UnknownReference').where('id' => ids).paginate(:page => options[:page])
    end

    results
  end

end
