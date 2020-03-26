# frozen_string_literal: true

module ReferenceHelper
  def reference_tab_active? reference, reference_class
    "is-active" if reference.is_a? reference_class
  end
end
