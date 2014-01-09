# coding: UTF-8
class MissingReferencesController < ApplicationController
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, if: :preview?

  def index
    @citations = 
      Protonym.select(:citation).
        joins(authorship: :reference).
        where("references.type = 'MissingReference'").
        order(:citation).
        group(:citation).
        all.
        map(&:citation)
  end

  def update
    index
    render :index
  end

end
