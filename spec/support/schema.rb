ActiveRecord::Schema.define do
  self.verbose = false

  create_table :authors, force: true do |t|
    t.string :name, nil: false

    t.timestamps
  end
  
  create_table :postings, force: true do |t|
    t.string :title, nil: false
    t.text :content, description: false
    t.integer :author_id, nil: false

    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.string :title, nil: false
    t.text :comment
    t.integer :author_id
    t.integer :posting_id

    t.timestamp
  end

end