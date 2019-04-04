class AddPlaceToPublishers < ActiveRecord::Migration[5.1]
  def change
    add_column :publishers, :place_name, :string

    # reversible do |dir|
    #   dir.up do
    #     antcat_bot = User.find 62
    #     PaperTrail.whodunnit = antcat_bot.id
    #
    #     Publisher.find_each do |publisher|
    #       publisher.update place_name: publisher.place.name
    #     end
    #   end
    # end
  end
end
