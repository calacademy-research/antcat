class SiteNoticesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :ensure_can_edit_catalog, except: [:index, :show, :mark_all_as_read]
  before_action :authenticate_superadmin, only: :destroy
  before_action :set_site_notice, only: [:show, :edit, :update, :destroy]
  before_action :mark_as_read, only: :show

  def index
    @site_notices = SiteNotice.order_by_date.paginate(page: params[:page], per_page: 10)
  end

  def show
    @new_comment = Comment.build_comment @site_notice, current_user
  end

  def new
    @site_notice = SiteNotice.new
  end

  def edit
  end

  def create
    @site_notice = SiteNotice.new site_notice_params
    @site_notice.user = current_user

    if @site_notice.save
      redirect_to @site_notice, notice: "Successfully created site notice."
    else
      render :new
    end
  end

  def update
    if @site_notice.update site_notice_params
      redirect_to @site_notice, notice: "Successfully updated site notice."
    else
      render :edit
    end
  end

  def destroy
    @site_notice.destroy
    redirect_to site_notices_path, notice: "Site notice was successfully deleted."
  end

  def mark_all_as_read
    SiteNotice.mark_as_read! :all, for: current_user
    redirect_back fallback_location: root_path,
      notice: "All site notices successfully marked as read."
  end

  private

    def set_site_notice
      @site_notice = SiteNotice.find(params[:id])
    end

    def site_notice_params
      params.require(:site_notice).permit :title, :message
    end

    def mark_as_read
      @site_notice.mark_as_read! for: current_user
    end
end
