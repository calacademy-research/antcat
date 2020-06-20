# frozen_string_literal: true

class ProtonymsController < ApplicationController
  TAXON_COUNT_ORDER = "taxon_count"

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]

  # TODO: Fix.
  def index
    protonyms =
      if current_user
        scope = Protonym.select("protonyms.*, COUNT(taxa.id) AS taxa_count").
                  left_outer_joins(:taxa).group(:id).references('taxa_count').
                  preload(:name, authorship: :reference)
        if params[:order] == TAXON_COUNT_ORDER
          scope.order("taxa_count DESC")
        else
          scope.order_by_name
        end
      else
        Protonym.includes(:name, authorship: :reference).order_by_name
      end
    @protonyms = protonyms.paginate(page: params[:page], per_page: 50)
  end

  def show
    @protonym = Protonym.eager_load(:name, :authorship).find(params[:id])
  end

  def new
    @protonym = Protonym.new
    @protonym.build_authorship
    @protonym_form = ProtonymForm.new(@protonym)
  end

  def create
    @protonym = Protonym.new
    @protonym.build_authorship
    @protonym_form = ProtonymForm.new(@protonym, protonym_params, protonym_form_params)

    if @protonym_form.save
      @protonym.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully created.'
    else
      render :new
    end
  end

  def edit
    @protonym = find_protonym
    @protonym_form = ProtonymForm.new(@protonym)
  end

  def update
    @protonym = find_protonym
    @protonym_form = ProtonymForm.new(@protonym, protonym_params, protonym_form_params)

    if @protonym_form.save
      @protonym.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    protonym = find_protonym

    if Protonyms::WhatLinksHere.new(protonym).any?
      redirect_to protonym_what_links_here_path(protonym),
        alert: "Other records refer to this protonym, so it can't be deleted."
      return
    end

    if protonym.destroy
      protonym.create_activity :destroy, current_user
      redirect_to protonyms_path, notice: "Successfully deleted protonym."
    else
      redirect_to protonym, alert: protonym.errors.full_messages.to_sentence
    end
  end

  private

    def find_protonym
      Protonym.find(params[:id])
    end

    def protonym_params
      params.require(:protonym).permit(
        *ProtonymForm::ATTRIBUTES.map(&:to_sym),
        authorship_attributes: [:pages, :reference_id],
        type_name_attributes: [:taxon_id, :fixation_method, :pages, :reference_id]
      )
    end

    def protonym_form_params
      params.permit(:protonym_name_string, :destroy_type_name)
    end
end
