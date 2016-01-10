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
    # This extra check (for change_type deleted) covers the case when we've deleted children
    # in a change that only shows the parent being deleted.
    unless helpers.current_user.nil?
      if (!change[:change_type] == 'delete' && taxon.can_be_edited_by?(helpers.current_user)) or helpers.current_user.can_edit
        unless change.versions.empty?
          helpers.button 'Undo', 'undo_button', 'data-undo-id' => change.id, class: "undo_button_#{change.id}"
        end
      end
    end
  end

  def approve_button
    taxon = change.get_most_recent_valid_taxon
    taxon_id = change.user_changed_taxon_id
    taxon_state = TaxonState.find_by taxon_id: taxon_id

    unless taxon_state.review_state == "approved"
      if (taxon.taxon_state.nil? and $Milieu.user_is_editor? helpers.current_user) or
          (!taxon_state.nil? and taxon.can_be_approved_by? change, helpers.current_user)
        helpers.button 'Approve', 'approve_button', 'data-change-id' => change.id
      end
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
      helpers.content_tag :span, "#{time_ago_in_words time} ago", title: time
    end

end
