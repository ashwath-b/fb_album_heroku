class CreatePhotoLinks < ActiveRecord::Migration
  def change
    create_table :photo_links do |t|
      t.integer :user_id
      t.string :link

      t.timestamps
    end
  end
end
