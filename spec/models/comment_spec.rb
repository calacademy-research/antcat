require 'rails_helper'

describe Comment do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_length_of(:body).is_at_most(described_class::BODY_MAX_LENGTH) }
  end
end
