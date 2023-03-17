# frozen_string_literal: true

module ReferencesHelper
  def add_to_recently_used_references_link reference
    link_to "Add to Recently Used", my_recently_used_references_path(id: reference.id),
      method: :post, remote: true, class: "btn-saves",
      "data-action" => "ajax:success->notify#success",
      "data-notify-message-param" => "Added to recently used references"
  end
end
