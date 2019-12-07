module Taxa
  class CreateCombinationsController < ApplicationController
    before_action :ensure_user_is_editor
    before_action :set_taxon
    before_action :set_new_parent, only: [:show, :create]
    before_action :set_target_name, only: [:show, :create]

    def new
      @create_combination_policy = CreateCombinationPolicy.new(@taxon)
    end

    def show
      redirect_to({ action: :new }, alert: "Target must be specified.") unless @new_parent
    end

    def create
      operation = ::Operations::CreateNewCombination.new(
        current_valid_taxon: @taxon,
        new_genus: @new_parent,
        target_name_string: target_name_string
      ).tap { |object| object.extend RunInTransaction }.run

      if operation.success?
        new_combination = operation.results.new_combination
        create_activity new_combination
        redirect_to catalog_path(new_combination), notice: "Successfully created new combination."
      else
        flash.now[:alert] = operation.context.errors.to_sentence
        render :show
      end
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_new_parent
        @new_parent = Taxon.find_by(id: params[:new_parent_id])
      end

      def target_name_string
        return unless @new_parent
        "#{@new_parent.name.name} #{params[:species_epithet]}"
      end

      def set_target_name
        @target_name = Names::BuildNameFromString[target_name_string]
      end

      def create_activity new_combination
        new_combination.create_activity :create_new_combination, current_user,
          parameters: { previous_combination_id: @taxon.id }
      end
  end
end
