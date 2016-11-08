RSpec::Matchers.define :have_formatted_review_state do |expected|
  match do |reference|
    actual = reference.decorate.format_review_state
    actual == expected
  end
end
