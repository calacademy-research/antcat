require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "importing files" do
    it "should process only files beginning with numbers, and them in numerical order" do
      File.should_receive(:read).with('01. FORMICIDAE.htm').ordered.and_return ''
      File.should_receive(:read).with('02. DOLICHODEROMORPHS.htm').ordered.and_return ''
      File.should_not_receive(:read).with('NGC-GEN.A-L.htm')
      @subfamily_catalog.import_files ['NGC-GEN.A-L.htm', '02. DOLICHODEROMORPHS.htm', '01. FORMICIDAE.htm']
    end
  end
end

