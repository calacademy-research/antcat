require "spec_helper"

describe Notification do
  it { should validate_presence_of :user }
  it { should validate_presence_of :notifier }
  it { should validate_presence_of :reason }
end
