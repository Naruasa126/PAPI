class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.text :contents
      t.string :address
      t.string :image_id
      t.integer :user_id

      t.timestamps
    end
  end
end
