require "spec_helper"

describe SiteNotice do
  it { should be_versioned }
  it { should validate_presence_of :title }
  it { should validate_presence_of :message }
  it { should validate_presence_of :user }
  it { should validate_length_of(:title).is_at_most 70 }
end
