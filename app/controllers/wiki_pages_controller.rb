# frozen_string_literal: true

class WikiPagesController < ApplicationController
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index, :show]
  before_action :ensure_user_is_superadmin, only: :destroy

  def index
    @wiki_pages = WikiPage.order(:title).paginate(page: params[:page], per_page: 30)
    @recent_activities = Activity.wiki_page_activities.most_recent_first.limit(5).includes(:user)
  end

  def show
    @wiki_page = find_wiki_page
  end

  def new
    @wiki_page = WikiPage.new
  end

  def create
    @wiki_page = WikiPage.new(wiki_page_params)

    if @wiki_page.save
      @wiki_page.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @wiki_page, notice: "Successfully created wiki page."
    else
      render :new
    end
  end

  def edit
    @wiki_page = find_wiki_page
  end

  def update
    @wiki_page = find_wiki_page

    if @wiki_page.update(wiki_page_params)
      @wiki_page.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      redirect_to @wiki_page, notice: "Successfully updated wiki page."
    else
      render :edit
    end
  end

  def destroy
    wiki_page = find_wiki_page

    wiki_page.destroy!
    wiki_page.create_activity Activity::DESTROY, current_user

    redirect_to wiki_pages_path, notice: "Wiki page was successfully deleted."
  end

  private

    def find_wiki_page
      WikiPage.find(params[:id])
    end

    def wiki_page_params
      params.require(:wiki_page).permit(:content, :title, :featured)
    end
end
