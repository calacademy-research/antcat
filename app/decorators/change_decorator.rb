class ChangeDecorator < Draper::Decorator
  delegate_all

  # WIP

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

  def undo_button
    taxon = change.get_most_recent_valid_taxon
    return unless helpers.current_user
    return if change.versions.empty?
    # This extra check (for change_type deleted) covers the case when we've deleted children
    # in a change that only shows the parent being deleted.

    if !change.change_type == 'delete' && helpers.user_can_edit?
      show_button = true
    end

    if show_button || helpers.current_user.can_edit
      helpers.link_to "Undo", "#", id: "undo_button_#{change.id}",
        class: "btn-destructive", data: { 'undo-id' => change.id }
    end
  end

  def approve_button
    taxon = change.get_most_recent_valid_taxon
    taxon_id = change.user_changed_taxon_id
    taxon_state = TaxonState.find_by taxon_id: taxon_id

    return if taxon_state.review_state == "approved"

    # Editors can approve taxa with no associated taxon_state
    if taxon.taxon_state.nil? && helpers.user_can_edit?
      show_button = true
    end

    # Another check from `can_be_approved_by?` (taxon_workflow.rb)
    if !taxon_state.nil? && taxon.can_be_approved_by?(change, helpers.current_user)
      show_button = true
    end

    if show_button
      helpers.link_to 'Approve', helpers.approve_change_path(change),
        method: :put, class: "btn-normal",
        data: { confirm: "Are you sure you want to approve this change?" }
    end
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
      helpers.content_tag :span, "#{helpers.time_ago_in_words time} ago", title: time
    end

end
