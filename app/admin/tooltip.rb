ActiveAdmin.register Tooltip do
  permit_params :scope, :key, :key_enabled, :text, :selector, :selector_enabled

  index do
    selectable_column
    id_column
    column :scope
    column :key
    column :key_enabled
    column :text
    column :selector
    column :selector_enabled
    actions
  end

  filter :scope
  filter :key
  filter :key_enabled
  filter :text
  filter :selector
  filter :selector_enabled

  form do |f|
    f.inputs "Tooltip Details" do
      f.input :scope
      f.input :key
      f.input :key_enabled
      f.input :text
      f.input :selector
      f.input :selector_enabled
    end
    f.actions
  end

  # From https://github.com/activeadmin/activeadmin/wiki/Auditing-via-paper_trail-(change-history)
  controller do
    def show
        @tooltip = Tooltip.includes(versions: :item).find(params[:id])
        @versions = @tooltip.versions
        @tooltip = @tooltip.versions[params[:version].to_i].reify if params[:version]
        show! #it seems to need this
    end
  end
  sidebar "Versions", partial: "shared/admin/version", only: :show

end
