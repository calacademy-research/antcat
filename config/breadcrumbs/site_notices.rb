# rubocop:disable Layout/IndentationConsistency
crumb :site_notices do
  link "Site Notices", site_notices_path
  parent :editors_panel
end

  crumb :site_notice do |site_notice|
    link site_notice.title, site_notice_path(site_notice)
    parent :site_notices
  end

    crumb :edit_site_notice do |site_notice|
      link "Edit"
      parent :site_notice, site_notice
    end

  crumb :new_site_notice do
    link "New"
    parent :site_notices
  end
# rubocop:enable Layout/IndentationConsistency
