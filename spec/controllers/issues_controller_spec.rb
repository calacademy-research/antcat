require 'rails_helper'

describe IssuesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:close, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:reopen, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "GET new" do
    before { sign_in create(:user, :helper) }

    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create" do
    let!(:issue_params) do
      {
        title: 'title',
        description: 'description'
      }
    end

    before { sign_in create(:user, :helper) }

    it 'creates an issue' do
      expect { post(:create, params: { issue: issue_params }) }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.title).to eq issue_params[:title]
      expect(issue.description).to eq issue_params[:description]
    end

    it 'creates an activity' do
      expect { post(:create, params: { issue: issue_params, edit_summary: 'summary' }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      issue = Issue.last
      expect(activity.trackable).to eq issue
      expect(activity.edit_summary).to eq "summary"
      expect(activity.parameters).to eq(title: issue.title)
    end
  end

  describe "PUT update" do
    let!(:issue) { create :issue }
    let!(:issue_params) do
      {
        title: 'title2',
        description: 'description2'
      }
    end

    before { sign_in create(:user, :helper) }

    it 'updates the protonym' do
      put(:update, params: { id: issue.id, issue: issue_params })

      issue.reload
      expect(issue.title).to eq issue_params[:title]
      expect(issue.description).to eq issue_params[:description]
    end

    it 'creates an activity' do
      expect { post(:create, params: { issue: issue_params, edit_summary: 'summary' }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      issue = Issue.last
      expect(activity.trackable).to eq issue
      expect(activity.edit_summary).to eq "summary"
      expect(activity.parameters).to eq(title: issue.title)
    end
  end
end
