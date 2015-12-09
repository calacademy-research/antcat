class ChangeDecorator < Draper::Decorator
  delegate_all

  # very much WIP

  def format_adder_name
    user_verb = case change.change_type
                when "create" then "added"
                when "delete" then "deleted"
                else               "changed"
                end

     name = format_changed_by
    "#{name} #{user_verb}".html_safe
  end

  def format_approver_name
    name = format_approved_by
    "#{name} approved this change".html_safe
  end

  def format_changed_by
    format_username change.changed_by
  end

  def format_approved_by
    format_username change.approver
  end

  def format_created_at
    format_time_ago change.created_at
  end

  def format_approved_at
    format_time_ago change.approved_at
  end

  private
    def format_username user
      if user
        user.decorate.format_doer_name
      else
        "Someone"
      end
    end

    # duplicated from ApplicationHelper
    def format_time_ago time
      return unless time
      helpers.content_tag :span, "#{time_ago_in_words time} ago", title: time
    end

end
