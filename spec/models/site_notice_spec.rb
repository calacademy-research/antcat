# frozen_string_literal: true

require 'rails_helper'

describe SiteNotice do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_MAX_LENGTH) }
    it { is_expected.to validate_presence_of :message }
  end
end
