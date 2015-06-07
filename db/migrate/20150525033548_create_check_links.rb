class CreateCheckLinks < ActiveRecord::Migration
  def change
    create_table :check_links do |t|
      t.text :checked_url
      t.integer :errors_found

      t.timestamps null: false
    end
  end
end
