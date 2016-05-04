class TasksController < ApplicationController
  before_filter :authenticate_editor, except: [:index, :show]
  before_filter :set_task, only: [:show, :edit, :update, :reopen, :complete, :close]

  def index
    @tasks = Task.by_status_and_date.paginate(page: params[:page])
    @open_task_count = Task.open.count
  end

  def show
    @new_comment = Comment.build_comment @task, current_user
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new task_params
    @task.adder = current_user

    if @task.save
      flash[:notice] = <<-MSG.html_safe
        Successfully created task.
        <strong>#{view_context.link_to 'Back to the index', tasks_path}</strong>
        or
        <strong>#{view_context.link_to 'create another?', new_task_path}</strong>
      MSG
      redirect_to @task
    else
      render :new
    end
  end

  def update
    if @task.update task_params
      redirect_to @task, notice: "Successfully updated task."
    else
      render action: "edit"
    end
  end

  def complete
    @task.set_status "completed", current_user
    redirect_to @task, notice: <<-MSG
      Successfully marked task as completed.
      <strong>#{view_context.link_to 'Back to the index', tasks_path}</strong>.
    MSG
  end

  def close
    @task.set_status "closed", current_user
    redirect_to @task, notice: <<-MSG
      Successfully closed task.
      <strong>#{view_context.link_to 'Back to the index', tasks_path}</strong>.
    MSG
  end

  def reopen
    @task.set_status "open", current_user
    redirect_to @task, notice: "Successfully re-opened task."
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description)
    end
end
