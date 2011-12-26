# coding: UTF-8
require 'spec_helper'

describe Bolton::ReferenceKey do

  it "should handle multiple authors" do
    Bolton::ReferenceKey.new('Lattke, J.E., Fernandez, F. & Palacio, E.E.', '1981').to_s(:db).should ==
      'Lattke Fernandez Palacio 1981'
  end

  it "should handle zero authors" do
    Bolton::ReferenceKey.new('', '1981').to_s(:db).should == '1981'
    Bolton::ReferenceKey.new(nil, '1981').to_s(:db).should == '1981'
  end

end
