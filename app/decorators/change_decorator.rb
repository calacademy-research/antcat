class ChangeDecorator < Draper::Decorator
  delegate_all

  # Accepts optional `user` for performance reasons.
  def format_adder_name user = nil
    user_verb = case change.change_type
                when "create" then "added"
                when "delete" then "deleted"
                else               "changed"
                end

    name = if user
             format_username user
           else
             format_changed_by
           end

    "#{name} #{user_verb}".html_safe
  end

  def format_approver_name
    "#{format_approved_by} approved this change".html_safe
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

  def undo_button _taxon
    # TODO sort this out
    # This is the snippet that was moved here from ChangesHelper
    #   # This extra check (for change_type deleted) covers the case when we've deleted children
    #   # in a change that only shows the parent being deleted.
    #   unless current_user.nil?
    #     if  (!change[:change_type] == 'delete' && taxon.can_be_edited_by?(current_user)) or current_user.can_edit
    #       if change.versions.size > 0
    #         button 'Undo', 'undo_button', 'data-undo-id' => change.id, class: 'undo_button_' + change.id.to_s
    #       end
    #     end
    #   end
    #
    # But it looks like the extra check is always ignored? Move stuff around and
    # after a while it will look like this:
    #   return unless helpers.user_can_edit? || change.versions.present?
    #
    #   if change.change_type == 'delete' || helpers.user_can_edit?
    #     button 'Undo', 'undo_button', 'data-undo-id' => change.id,
    #       class: 'undo_button_' + change.id.to_s
    #   end
    #
    # `taxon.can_be_edited_by?` [now removed, at least temporarily], effectively
    # did the same thing as `helpers.user_can_edit?`

    return unless helpers.user_can_edit? || change.versions.present?

    helpers.link_to "Undo", "#", class: "btn-undo", data: { 'undo-id' => change.id }
  end

  def approve_button taxon, changed_by: nil
    return unless helpers.user_can_edit?
    return if taxon.approved?

    # TODO clarify this; does the nil check mean that editors are allowed
    # to approve their own changes if the taxon has no taxon_state?
    #
    # Editors can approve taxa with no associated taxon_state. The GUI probably
    # does not allow for this to happen, just an additional check (?).
    if taxon.taxon_state.nil? || taxon.can_be_approved_by?(change, helpers.current_user, changed_by)
      helpers.link_to 'Approve', helpers.approve_change_path(change),
        method: :put, class: "btn-normal",
        data: { confirm: "Are you sure you want to approve this change?" }
    end
  end

  private
    def format_username user
      return "Someone" unless user # Sometimes we get here with a nil user.
      user.decorate.name_linking_to_email
    end

    def format_time_ago time
      return unless time
      helpers.content_tag :span, "#{helpers.time_ago_in_words time} ago"
    end
end
