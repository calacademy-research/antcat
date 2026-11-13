# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('script/code_headers')

# Every Ruby file of app/ and lib/ has a header comment saying what it does (script/code_headers.rb has the rule).
# docs/catalog/headers-missing.txt lists the files still without one; it only shrinks.
describe "Code headers (script/code_headers.rb)" do # rubocop:disable RSpec/DescribeClass
  let(:missing) { CodeHeaders.missing }
  let(:baseline) { CodeHeaders.baseline }

  it "finds a header in every new file" do
    new_without = missing - baseline
    expect(new_without).to be_empty,
      "these files need a header comment (what the file does, in a sentence or two, before its class): " \
      "#{new_without.join(', ')}"
  end

  it "keeps the list of files without a header current" do
    done = baseline - missing
    expect(done).to be_empty, "these files have a header now: take their lines out of " \
                              "#{CodeHeaders::BASELINE}: #{done.join(', ')}"
  end

  it "does not let the list grow" do
    expect(baseline.size).to be <= CodeHeaders::BASELINE_MAX,
      "#{CodeHeaders::BASELINE} may hold at most #{CodeHeaders::BASELINE_MAX} files: write the header instead"
  end

  it "lists only files that exist" do
    gone = baseline - CodeHeaders.files
    expect(gone).to be_empty, "#{CodeHeaders::BASELINE} lists files that are gone: #{gone.join(', ')}"
  end

  it "knows a header when it sees one" do
    Dir.mktmpdir do |dir|
      check = lambda do |source|
        File.write(File.join(dir, 'x.rb'), source)
        stub_const('CodeHeaders::ROOT', dir)
        CodeHeaders.header?('x.rb')
      end
      expect(check.call("# frozen_string_literal: true\n\n# Shows the taxa of a genus.\nclass X\nend\n")).to be true
      expect(check.call("module A\n  # Shows the taxa of a genus.\n  class X\n  end\nend\n")).to be true
      expect(check.call("# frozen_string_literal: true\n\nclass X\n  # Shows the taxa of a genus.\n  def y; end\nend\n")).to be false
      expect(check.call("# frozen_string_literal: true\n\n# rubocop:disable Metrics/ClassLength\nclass X\nend\n")).to be false
      expect(check.call("class X\nend\n")).to be false
      expect(check.call("class X\n  # Builds the thing for the form.\n  class Inner\n  end\nend\n")).to be false
      expect(check.call("module A\n  # Shows the taxa of a genus.\n  class X < Struct.new(:a) # :nodoc:\n  end\nend\n")).to be true
    end
  end

  it "accepts a rake file's desc and a database script's __END__ block" do
    Dir.mktmpdir do |dir|
      stub_const('CodeHeaders::ROOT', dir)
      FileUtils.mkdir_p(File.join(dir, CodeHeaders::DATABASE_SCRIPTS))
      File.write(File.join(dir, 'x.rake'), "namespace :a do\n  desc 'Exports the taxa for AntWeb'\n  task :b do\n  end\nend\n")
      script = File.join(CodeHeaders::DATABASE_SCRIPTS, 'y.rb')
      File.write(File.join(dir, script), "module DatabaseScripts\n  class Y\n  end\nend\n\n__END__\n\nsection: list\n")
      expect(CodeHeaders.header?('x.rake')).to be true
      expect(CodeHeaders.header?(script)).to be true
    end
  end
end
