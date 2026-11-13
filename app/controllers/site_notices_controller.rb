# frozen_string_literal: true

# Notices shown to editors on the site.
#
# Routes: POST /site_notices/mark_all_as_read (signed in); GET /site_notices (anyone); POST /site_notices (editors);
# GET /site_notices/new (editors); GET /site_notices/:id/edit (editors); GET /site_notices/:id (signed in); PATCH
# /site_notices/:id (editors); PUT /site_notices/:id (editors); DELETE /site_notices/:id (superadmins). Purpose,
# rights and tests of each: docs/catalog/routes.tsv.
class SiteNoticesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :ensure_user_is_editor, except: [:index, :show, :mark_all_as_read]
  before_action :ensure_user_is_superadmin, only: :destroy
  before_action :mark_as_read, only: :show # NOTE: `before_action` to mark it as read for the current render.

  def index
    @site_notices = SiteNotice.most_recent_first.paginate(page: params[:page], per_page: 20)
  end

  def show
    @site_notice = find_site_notice
    @new_comment = Comment.build_comment(@site_notice, current_user)
  end

  def new
    @site_notice = SiteNotice.new
  end

  def create
    @site_notice = SiteNotice.new(site_notice_params)
    @site_notice.user = current_user

    if @site_notice.save
      @site_notice.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
      Notifications::NotifyMentionedUsers[@site_notice.message, attached: @site_notice, notifier: current_user]
      redirect_to @site_notice, notice: "Successfully created site notice."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @site_notice = find_site_notice
  end

  def update
    @site_notice = find_site_notice

    if @site_notice.update(site_notice_params)
      @site_notice.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
      Notifications::NotifyMentionedUsers[@site_notice.message, attached: @site_notice, notifier: current_user]
      redirect_to @site_notice, notice: "Successfully updated site notice."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    site_notice = find_site_notice

    site_notice.destroy!
    site_notice.create_activity Activity::DESTROY, current_user

    redirect_to site_notices_path, notice: "Site notice was successfully deleted."
  end

  def mark_all_as_read
    SiteNotice.mark_as_read! :all, for: current_user
    redirect_back_or_to(root_path, notice: "All site notices successfully marked as read.")
  end

  private

    def find_site_notice
      SiteNotice.find(params.expect(:id))
    end

    def site_notice_params
      params.expect(site_notice: [:message, :title])
    end

    def mark_as_read
      find_site_notice.mark_as_read! for: current_user
    end
end
