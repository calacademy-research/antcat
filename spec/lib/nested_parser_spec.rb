require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NestedParser do

  describe "if it's not a nested reference" do
    describe "if it's empty" do
      it "should return nil" do
        [nil, ''].each do |citation|
          NestedParser.parse(citation).should == nil
        end
      end
    end

    describe "if it's a book citation" do
      it "should return nil" do
        NestedParser.parse('New York: Longmans, 36 pp.').should == nil
      end
    end
  end

  describe "parsing" do
    it "should work on a simple nesting" do
      parts = NestedParser.parse('Pp. 32-45 in Mayer, D.M. Ants. Psyche 1:2')
      parts.should == {
        :nested => {
          :authors => ['Mayer, D.M.'],
          :title => 'Ants',
          :article => {
            :journal => 'Psyche',
            :series_volume_issue => '1',
            :pagination => '2',
          },
          :pages_in => 'Pp. 32-45 in',
        }
      }
    end

    it "should work on a slightly harder nesting" do
      parts = NestedParser.parse 'Pp. 96-98 in: MacKay, W., Lowrie, D., Fisher, A., MacKay, E., Barnes, F., Lowrie, D.  The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae). New York: Harpers, 36 pp.'
      parts.should == {
        :nested => {
          :authors => ['MacKay, W.', 'Lowrie, D.', 'Fisher, A.', 'MacKay, E.', 'Barnes, F.', 'Lowrie, D.'],
          :title => 'The ants of Los Alamos County, New Mexico (Hymenoptera: Formicidae)',
          :book => {
            :publisher => {:name => 'Harpers', :place => 'New York'},
            :pagination => '36 pp.'
          },
          :pages_in => 'Pp. 96-98 in:',
        }
      }
    end
  end



end
