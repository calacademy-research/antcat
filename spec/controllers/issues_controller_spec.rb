require 'rails_helper'

describe IssuesController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:close, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:reopen, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :user do
    let!(:issue) { create :issue }

    specify { expect(get(:show, params: { id: issue.id })).to render_template :show }
  end

  describe "GET new", as: :user do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :user do
    let!(:issue_params) do
      {
        title: 'title',
        description: 'description',
        help_wanted: true
      }
    end

    it 'creates an issue' do
      expect { post(:create, params: { issue: issue_params }) }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.title).to eq issue_params[:title]
      expect(issue.description).to eq issue_params[:description]
      expect(issue.help_wanted).to eq issue_params[:help_wanted]
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

  describe "GET edit", as: :user do
    let!(:issue) { create :issue }

    specify { expect(get(:edit, params: { id: issue.id })).to render_template :edit }
  end

  describe "PUT update", as: :user do
    let!(:issue) { create :issue }
    let!(:issue_params) do
      {
        title: 'title2',
        description: 'description2'
      }
    end

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
