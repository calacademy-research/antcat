# frozen_string_literal: true

class JournalsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index, :show]

  def index
    @journals = JournalQuery.new.includes_reference_count.with_order(params[:order]).paginate(page: params[:page], per_page: 100)
  end

  def show
    @journal = find_journal
    @references = @journal.references.order(:year).includes(:document).paginate(page: params[:page])
  end

  def edit
    @journal = find_journal
  end

  def update
    @journal = find_journal

    if @journal.update(journal_params)
      @journal.create_activity Activity::UPDATE, current_user
      References::Cache::Invalidate[@journal.references]
      redirect_to @journal, notice: "Successfully updated journal."
    else
      render :edit
    end
  end

  def destroy
    journal = find_journal

    if journal.destroy
      journal.create_activity Activity::DESTROY, current_user
      redirect_to references_path, notice: "Journal was successfully deleted."
    else
      redirect_to journal, alert: journal.errors.full_messages.to_sentence
    end
  end

  private

    def find_journal
      Journal.find(params[:id])
    end

    def journal_params
      params.require(:journal).permit(:name)
    end
end
