class CreateAliases < ActiveRecord::Migration
  def self.up
    create_table :aliases do |t|
      t.text :alias
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :aliases
  end
end
