require 'dm-migrations/migration_runner'

# property :id,           Serial
# # property :source_id,    Integer, required: true
# property :title,        Text
# property :description,  Text
# property :content,      Text
# property :version,      String
# property :published_at, DateTime
# property :created_at,   DateTime

migration 0002, :create_items_table do
  up do
    create_table :items do
      column :id,           Integer, serial: true
      column :source_id,    Integer, required: true
      column :title,        'text', required: true
      column :description,  'text'
      column :content,      'text'
      column :version,      String
      column :origin,       String, required: true
      column :published_at, DateTime

      column :created_at,   DateTime
      column :updated_at,   DateTime
    end
  end
  down do
    drop_table :items
  end
end
