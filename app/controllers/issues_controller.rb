class IssuesController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show]
  before_action :set_issue, only: [:show, :edit, :update, :reopen, :close]

  def index
    @issues = Issue.by_status_and_date.paginate(page: params[:page])
    @open_issues_count = Issue.open.count
  end

  def show
    @new_comment = Comment.build_comment @issue, current_user
  end

  def new
    @issue = Issue.new
  end

  def edit
  end

  def create
    @issue = Issue.new issue_params
    @issue.adder = current_user

    if @issue.save
      flash[:notice] = <<-MSG.html_safe
        Successfully created issue.
        <strong>#{view_context.link_to 'Back to the index', issues_path}</strong>
        or
        <strong>#{view_context.link_to 'create another?', new_issue_path}</strong>
      MSG
      redirect_to @issue
    else
      render :new
    end
  end

  def update
    if @issue.update issue_params
      redirect_to @issue, notice: "Successfully updated issue."
    else
      render action: "edit"
    end
  end

  def close
    @issue.close! current_user

    redirect_to @issue, notice: <<-MSG
      Successfully closed issue.
      <strong>#{view_context.link_to 'Back to the index', issues_path}</strong>.
    MSG
  end

  def reopen
    @issue.reopen!

    redirect_to @issue, notice: "Successfully re-opened issue."
  end

  def autocomplete
    q = params[:q] || ''

    # See if we have an exact ID match.
    search_results = if q =~ /^\d+ ?$/
                       id_matches_q = Issue.find_by id: q
                       [id_matches_q] if id_matches_q
                     end

    search_results ||= Issue.where("title LIKE ?", "%#{q}%")

    respond_to do |format|
      format.json do
        results = search_results.map do |issue|
          { id: issue.id, title: issue.title, status: issue.decorate.format_status }
        end
        render json: results
      end
    end
  end

  private
    def set_issue
      @issue = Issue.find params[:id]
    end

    def issue_params
      params.require(:issue).permit :title, :description
    end
end
