class ChangeDecorator < Draper::Decorator
  delegate_all

  def format_adder_name
    change_type = change.change_type
    user = change.changed_by

    if change_type == "create"
      user_verb = "added"
    elsif change_type == "delete"
      user_verb = "deleted"
    else
      user_verb = "changed"
    end

    "#{user.decorate.format_doer_name} #{user_verb}".html_safe
  end

  def format_approver_name
    user = change.approver
    "#{user.decorate.format_doer_name} approved this change".html_safe
  end

end
