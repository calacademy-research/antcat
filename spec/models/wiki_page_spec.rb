# frozen_string_literal: true

require 'rails_helper'

describe WikiPage do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :content }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_MAX_LENGTH) }

    describe "uniqueness validation" do
      subject { create :wiki_page }

      it { is_expected.to validate_uniqueness_of(:title).ignoring_case_sensitivity }
      it { is_expected.to validate_uniqueness_of(:permanent_identifier).ignoring_case_sensitivity }
    end
  end
end
