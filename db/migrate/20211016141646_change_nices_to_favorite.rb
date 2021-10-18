class ChangeNicesToFavorite < ActiveRecord::Migration[5.2]
  def change
    rename_table :nices, :favorite
  end
end
