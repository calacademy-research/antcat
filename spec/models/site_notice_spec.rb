require "spec_helper"

describe SiteNotice do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:message) }
  it { should validate_presence_of(:user) }
  it { should validate_length_of(:title).is_at_most(70) }

  describe "versioning" do
    it "records versions" do
      with_versioning do
        site_notice = create :site_notice
        expect(site_notice.versions.last.event).to eq "create"
      end
    end
  end
end
