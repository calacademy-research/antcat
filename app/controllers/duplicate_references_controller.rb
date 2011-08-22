# coding: UTF-8
class DuplicateReferencesController < ApplicationController
  def index
    @references_with_duplicates = Reference.all(:order => 'references.principal_author_last_name_cache, references.citation_year').select do |reference|
      reference.duplicates.present?
    end
  end
end
