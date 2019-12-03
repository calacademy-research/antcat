require 'rails_helper'

describe SiteNotice do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :message }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_length_of(:title).is_at_most 70 }
end
