module ChangesHelper
  # TODO copy-pasted from `ChangesDecorator`.
  def format_change_type_verb change_type
    case change_type
    when "create" then "added"
    when "delete" then "deleted"
    else               "changed"
    end
  end
end
