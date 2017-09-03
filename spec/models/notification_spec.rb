require "spec_helper"

describe Notification do
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :notifier }
  it { is_expected.to validate_presence_of :reason }
end
