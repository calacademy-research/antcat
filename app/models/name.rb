# All `Name` subclasses are for taxa; `AuthorName`s are used for references;
# `ReferenceAuthorName` is used for ??????.

class Name < ApplicationRecord
  include Formatters::ItalicsHelper

  attr_accessible :epithet, :epithet, :epithet_html, :epithet_html, :epithets,
    :gender, :name, :name_html, :nonconforming_name, :type

  validates :name, presence: true

  after_save :set_taxon_caches

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes only: [:gender], replace_newlines: true

  # TODO rename to avoid confusing this with [Rails'] dynamic finder methods.
  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false)
      .where(name: string).order('taxa.id DESC').order(:name).first
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

  def what_links_here
    Names::WhatLinksHere[self]
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
      raise Taxon::TaxonExists if existing_names.any? { |name| not name.what_links_here.empty? }
      update! name: name_string, name_html: italicize(name_string)
    end
end
