# frozen_string_literal: true

require 'rails_helper'

describe Comment do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to belong_to(:commentable).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_length_of(:body).is_at_most(described_class::BODY_MAX_LENGTH) }
  end
end
