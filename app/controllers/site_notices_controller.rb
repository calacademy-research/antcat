# TODO probably remove the big 'unread site notices' box and just add a badge
# in the header, similar to the (soon) "new notifications" feature.

class SiteNoticesController < ApplicationController
  before_action :authenticate_editor
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
      flash[:notice] = <<-MSG.html_safe
        Successfully created site notice.
        <strong>#{view_context.link_to 'Back to the index', site_notices_path}</strong>
        or
        <strong>#{view_context.link_to 'create another?', new_site_notice_path}</strong>
      MSG
      redirect_to @site_notice
    else
      render :new
    end
  end

  def update
    if @site_notice.update site_notice_params
      redirect_to @site_notice, notice: "Successfully updated site notice."
    else
      render action: "edit"
    end
  end

  def destroy
    @site_notice.destroy
    redirect_to site_notices_path, notice: "Site notice was successfully deleted."
  end

  def mark_all_as_read
    SiteNotice.mark_as_read! :all, for: current_user
    flash[:notice] = "All site notices successfully marked as read."
    redirect_to :back
  end

  def dismiss
    session[:last_dismissed_site_notice_id] = SiteNotice.last.id
    redirect_to :back
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
