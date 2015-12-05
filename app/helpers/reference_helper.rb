# coding: UTF-8
module ReferenceHelper
  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_italics string
    Formatters::ReferenceFormatter.format_italics string
  end

  def format_timestamp timestamp
    Formatters::ReferenceFormatter.format_timestamp timestamp
  end

  def format_review_state review_state
    Formatters::ReferenceFormatter.format_review_state review_state
  end

  def approve_all_button
    if $Milieu.user_is_superadmin? current_user
      button 'Approve all', 'approve_all_button', class: 'approve_all'
    end
  end
end
