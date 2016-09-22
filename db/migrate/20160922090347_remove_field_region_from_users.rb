class RemoveFieldRegionFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :region, :integer
  end
end
