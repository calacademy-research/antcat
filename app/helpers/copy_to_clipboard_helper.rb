# frozen_string_literal: true

module CopyToClipboardHelper
  def copy_to_clipboard_button string_to_copy, label = nil
    tag.span label || string_to_copy,
      data: { copy_to_clipboard: string_to_copy },
      class: "btn-tiny btn-nodanger btn-copy-to-clipboard"
  end
end
