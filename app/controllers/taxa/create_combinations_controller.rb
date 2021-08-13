# frozen_string_literal: true

module Taxa
  class CreateCombinationsController < ApplicationController
    before_action :ensure_user_is_editor

    def new
      @taxon = find_taxon
      @create_combination_policy = CreateCombinationPolicy.new(@taxon)
    end

    def show
      @taxon = find_taxon
      @new_parent = find_new_parent
      @target_name = build_target_name(@new_parent)

      redirect_to({ action: :new }, alert: "Target must be specified.") unless @new_parent
    end

    def create
      @taxon = find_taxon
      @new_parent = find_new_parent
      @target_name = build_target_name(@new_parent)

      operation = ::Operations::CreateNewCombination.new(
        current_taxon: @taxon,
        new_genus: @new_parent,
        target_name_string: target_name_string(@new_parent)
      ).tap { |object| object.extend RunInTransaction }.run

      if operation.success?
        new_combination = operation.results.new_combination
        create_activity new_combination, @taxon
        redirect_to catalog_path(new_combination), notice: "Successfully created new combination."
      else
        flash.now[:alert] = operation.context.errors.to_sentence
        render :show
      end
    end

    private

      def find_taxon
        Taxon.find(params[:taxon_id])
      end

      def find_new_parent
        Taxon.find_by(id: params[:new_parent_id])
      end

      def target_name_string new_parent
        return unless new_parent
        "#{new_parent.name.name} #{params[:species_epithet]}"
      end

      def build_target_name new_parent
        Names::BuildNameFromString[target_name_string(new_parent)]
      end

      def create_activity new_combination, taxon
        new_combination.create_activity Activity::CREATE_NEW_COMBINATION, current_user,
          parameters: { previous_combination_id: taxon.id }
      end
  end
end
