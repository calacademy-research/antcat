# frozen_string_literal: true

class AuthorsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: [:destroy]

  def index
    @authors = Author.order_by_name.paginate(page: params[:page], per_page: 60).preload(:names)
  end

  def show
    @author = find_author
    @references = @author.references.order_by_suffixed_year.includes(:document).paginate(page: params[:references_page])
    @described_protonyms = @author.described_protonyms.order("references.year, references.id").
      includes(:name, authorship: :reference).
      paginate(page: params[:protonyms_page])
  end

  def destroy
    author = find_author

    if author.destroy
      author.create_activity Activity::DESTROY, current_user
      redirect_to authors_path, notice: 'Author was successfully deleted.'
    else
      redirect_to author, alert: 'Could not delete author.'
    end
  end

  private

    def find_author
      Author.find(params[:id])
    end
end
