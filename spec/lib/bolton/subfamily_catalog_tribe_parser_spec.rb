require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe 'Tribe line' do

    it "should be recognized" do
      @subfamily_catalog.parse(%{
<b><span lang="EN-GB">Acanthomyopsini</span></b><span lang="EN-GB"> Donisthorpe, 1943f: 618. Type-genus: <i>Acanthomyops</i>.</span>
      }).should == {:type => :tribe_line, :name => 'Acanthomyopsini'}
    end
    
  end
end
