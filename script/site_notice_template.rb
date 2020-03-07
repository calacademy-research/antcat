# TODO: See if we want to generate a changelog from commits.

class SiteNoticeTemplate
  def message
    <<~MARKDOWN
      Title (#{next_version_number})

      ##### Changes and new features

      * Zzz (%github)
      * Zzz (%github)
      * Zzz (%github)

      ##### New database scripts

      * %dbscript:Name


      ##### Grab bag changes

      * "3.3.-tweaks" (%github)
    MARKDOWN
  end

  def filename
    "site_notice_#{next_version_number}"
  end

  private

    def next_version_number
      @next_version_number ||= latest_tag.gsub(/\d$/) { |match| match.to_i + 1 }
    end

    def next_version_number00
      latest_tag.gsub(/\d$/) do |match|
        match.to_i + 1
      end
    end

    def latest_tag
      `git describe --tags $(git rev-list --tags --max-count=1)`.strip
    end
end
