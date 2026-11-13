# frozen_string_literal: true

# A button that copies a text to the clipboard (ids, taxt tags).
module CopyToClipboardHelper
  def copy_to_clipboard_button string_to_copy, label = nil
    tag.button label || string_to_copy,
      'data-action': 'click->clipboard#copy',
      'data-clipboard-string-to-copy-value': string_to_copy,
      'data-controller': 'clipboard',
      class: "btn-neutral font-courier"
  end
end
