# frozen_string_literal: true

module CopyToClipboardHelper
  def copy_to_clipboard_button string_to_copy, label = nil
    tag.button label || string_to_copy,
      'data-action': 'clipboard#copy',
      'data-clipboard-string-to-copy-value': string_to_copy,
      'data-controller': 'clipboard',
      class: "btn-tiny btn-nodanger btn-copy-to-clipboard"
  end
end
