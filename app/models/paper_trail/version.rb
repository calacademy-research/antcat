# Per http://stackoverflow.com/questions/35595171/why-do-methods-defined-in-an-initializer-intermittently-raise-a-not-defined-er

# Confirm that autoloading works after editing this file by going to
# the changes page and look for "<username and link> deleted <taxon>".
# Edit any autoloaded file and refresh the page. It should not say
# "Someone deleted <taxon>" this time.

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    include FilterableWhere

    attr_accessible :change_id

    def user
      User.find(whodunnit) if whodunnit
    end
  end
end
