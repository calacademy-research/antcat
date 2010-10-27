require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NestedReferenceParser do

  describe "if it's not a nested reference" do
    describe "if it's empty" do
      it "should return nil" do
        [nil, ''].each do |citation|
          NestedReferenceParser.parse(citation).should == nil
        end
      end
    end

    describe "if it's a book citation" do
      it "should return nil" do
        NestedReferenceParser.parse('New York: Longmans, 36 pp.').should == nil
      end
    end
  end

  describe "parsing" do
    it "should work" do
      parts = NestedReferenceParser.parse('Pp. 32-45 in Mayer, D.M. Ants. Psyche 1:2')
      parts.should == {
        :pages => '32-45',
        :reference => {
          :authors => ['Mayer, D.M.'],
          :title => 'Ants',
          :article => {
            :journal => 'Psyche',
            :series_volume_issue => '1',
            :pagination => '2',
          }
        }
      }
    end
  end

end
