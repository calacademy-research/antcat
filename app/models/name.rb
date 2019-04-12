# All `Name` subclasses are for taxa; `AuthorName`s are used for references.

class Name < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable

  has_many :protonyms, dependent: :restrict_with_error
  has_many :taxa, class_name: 'Taxon', dependent: :restrict_with_error

  validates :name, :epithet, presence: true

  after_save :set_taxon_caches

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  strip_attributes replace_newlines: true
  tracked on: :mixin_create_activity_only, parameters: proc { { name_html: name_html } }

  # TODO rename to avoid confusing this with [Rails'] dynamic finder methods.
  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false).
      where(name: string).order('taxa.id DESC').order(:name).first
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  def name_html
    name
  end

  def epithet_html
    epithet
  end

  def name_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def epithet_with_fossil_html fossil
    "#{dagger_html if fossil}#{epithet_html}".html_safe
  end

  def dagger_html
    '&dagger;'.html_safe
  end

  def what_links_here
    Names::WhatLinksHere[self]
  end

  def orphaned?
    !(taxa.exists? || protonyms.exists?)
  end

  private

    def words
      @words ||= name.split
    end

    def set_taxon_caches
      Taxon.where(name: self).update_all(name_cache: name, name_html_cache: name_html)
    end
end
