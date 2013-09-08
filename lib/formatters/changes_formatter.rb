# coding: UTF-8
module Formatters::ChangesFormatter
  extend self
  def format_approver_name user
    "#{format_doer_name(user)} approved this change".html_safe
  end
end
