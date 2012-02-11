# coding: UTF-8

# These are methods used either now or at one time by Rake tasks, not
# by application code, so could well be dead

class Reference < ActiveRecord::Base

  def self.import_hol_document_urls show_progress = false
    Importers::Hol::DocumentUrlImporter.new(show_progress).import
  end

  def replace_author_name old_name, new_author_name
    old_author_name = AuthorName.find_by_name old_name
    reference_author_name = reference_author_names.where(:author_name_id => old_author_name).first
    reference_author_name.author_name = new_author_name
    reference_author_name.save!
    author_names(true)
    refresh_author_names_caches
  end

end
