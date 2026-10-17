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

  describe 'scopes' do
    describe '.visible_to' do
      let!(:issue_comment) { create :comment, commentable: create(:issue) }
      let!(:feedback_comment) { create :comment, commentable: create(:feedback) }

      it 'hides comments on feedback items from visitors and unconfirmed users' do
        expect(described_class.visible_to(nil)).to contain_exactly(issue_comment)
        expect(described_class.visible_to(create(:user))).to contain_exactly(issue_comment)
      end

      it 'shows all comments to helpers and editors' do
        expect(described_class.visible_to(create(:user, :helper))).to contain_exactly(issue_comment, feedback_comment)
        expect(described_class.visible_to(create(:user, :editor))).to contain_exactly(issue_comment, feedback_comment)
      end
    end
  end
end
