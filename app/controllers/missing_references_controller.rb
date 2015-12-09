# coding: UTF-8
class MissingReferencesController < ApplicationController
  before_filter :authenticate_editor, except: [:index]
  skip_before_filter :authenticate_editor, if: :preview?

  def index
#      Unknown column 'protonyms.citation' in 'order clause':
#
#          SELECT citation FROM `protonyms`
#      INNER JOIN `citations`
#      ON `citations`.`id` = `protonyms`.`authorship_id`
# INNER JOIN `references`
# ON `references`.`id` = `citations`.`reference_id`
# WHERE (references.type = 'MissingReference')
# GROUP BY citation
# ORDER BY `protonyms`.`citation` ASC

    ids = Protonym.joins(authorship: :reference)
      .where("references.type = 'MissingReference'")
      .uniq.pluck('references.id')

    @missing_references = MissingReference.find(ids).sort_by(&:citation)
  end


  def edit
    @missing_reference = MissingReference.find params[:id]
    @replacement = nil
  end

  def update
    @missing_reference = MissingReference.find params[:id] rescue nil
    @replacement = Reference.find params[:replacement_id] rescue nil

    unless @replacement
      edit
      render :edit
      return
    end

    MissingReference.find(@missing_reference.id).replace_citation_with @replacement

    redirect_to missing_references_path
  end

end
