# coding: UTF-8

class ShouldOrShouldNot
  def initialize(should_or_should_not) @should_or_should_not = should_or_should_not end
  def to_s() @should_or_should_not end
  def to_sym() @should_or_should_not.gsub(/ /, '_').to_sym end
  def to_bool() @should_or_should_not !~ /not/ end
end

SHOULD_OR_SHOULD_NOT = Transform /^should(?: not)?$/ do |should_or_should_not|
  ShouldOrShouldNot.new should_or_should_not
end
