# All `Name` subclasses are for taxa; `AuthorName`s are used for references;
# `ReferenceAuthorName` is used for ??????.

# TODO generate HTML in callbacks in the subclasses, not manually in `Names::Parser`.

class Name < ApplicationRecord
  include Formatters::ItalicsHelper

  attr_accessible :epithet, :epithet, :epithet_html, :epithet_html, :epithets,
    :gender, :name, :name_html, :nonconforming_name, :type

  validates :name, presence: true

  after_save :set_taxon_caches

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.duplicates
    name_strings = Name.find_by_sql(<<-SQL).map(&:name)
      SELECT * FROM names GROUP BY name HAVING COUNT(*) > 1
    SQL
    Name.where(name: name_strings).order(:name)
  end

  def self.duplicates_with_references options = {}
    results = {}
    dupes = duplicates

    Progress.new_init show_progress: options[:show_progress], total_count: dupes.size, show_errors: true
    dupes.each do |duplicate|
      Progress.puts duplicate.name
      Progress.tally_and_show_progress 1
      results[duplicate.name] ||= {}
      results[duplicate.name][duplicate.id] = duplicate.references
    end
    Progress.show_results

    results
  end

  # TODO rename to avoid confusing this with [Rails'] dynamic finder methods.
  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false)
      .where(name: string).order('taxa.id DESC').order(:name).first
  end

  def self.make_epithet_set epithet
    EpithetSearchSet.new(epithet).epithets
  end

  def self.picklist_matching letters_in_name, options = {}
    Names::PicklistMatching.new(letters_in_name, options).call
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  # TODO maybe raise?
  def change_parent _; end

  # Only used in specs.
  def quadrinomial?
    name.split(' ').size == 4
  end

  # TODO remove? Too magical.
  def to_s
    name
  end

  def to_html
    name_html
  end

  def to_html_with_fossil fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def epithet_with_fossil_html fossil
    "#{dagger_html if fossil}#{epithet_html}".html_safe
  end

  def protonym_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def dagger_html
    '&dagger;'.html_safe
  end

  def references
    Names::WhatLinksHere.new(self).call
  end

  private
    def words
      @_words ||= name.split ' '
    end

    def set_taxon_caches
      Taxon.where(name: self).update_all(name_cache: name)
      Taxon.where(name: self).update_all(name_html_cache: name_html)
    end

    def change name_string
      existing_names = Name.where.not(id: id).where(name: name_string)
      raise Taxon::TaxonExists if existing_names.any? { |name| not name.references.empty? }
      update! name: name_string, name_html: italicize(name_string)
    end
end
