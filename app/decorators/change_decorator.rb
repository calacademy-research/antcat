class ChangeDecorator < Draper::Decorator
  delegate_all

  def format_adder_name
    user_verb = case change.change_type
                when "create" then "added"
                when "delete" then "deleted"
                else               "changed"
                end

    user = change.changed_by
    user_string = if user then user.decorate.format_doer_name
                  else "Someone" end

    "#{user_string} #{user_verb}".html_safe
  end

  def format_approver_name
    user = change.approver
    "#{user.decorate.format_doer_name} approved this change".html_safe
  end

end
