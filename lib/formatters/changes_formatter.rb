# coding: UTF-8
module Formatters::ChangesFormatter
  extend self
  def format_approver_name user
    "#{user ? user.name : 'Someone'} approved this change"
  end
end
