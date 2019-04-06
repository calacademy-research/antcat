class NamesController < ApplicationController
  before_action :ensure_can_edit_catalog, except: [:show]
  before_action :set_name, only: [:show, :edit, :update]

  def show
    @table_refs = @name.what_links_here
  end

  def edit
  end

  def update
    if @name.update name_params
      @name.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to name_path(@name), notice: "Successfully updated name."
    else
      render :edit
    end
  end

  private

    def set_name
      @name = Name.find(params[:id])
    end

    def name_type
      params[:type].underscore.to_sym
    end

    # NOTE: Not included: `:gender`, `:nonconforming_name`.
    def name_params
      params.require(name_type).permit(:name, :epithet, :epithets)
    end
end
