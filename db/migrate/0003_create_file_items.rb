require 'dm-migrations/migration_runner'

# property :id,         Serial
# # property :item_id,    Integer, required: true
# property :url,        String, required: true
# property :path,       String
# property :loaded_at,  DateTime
# property :created_at, DateTime
# property :md5sum,     String, length: 32

migration 0002, :create_file_items_table do
  up do
    create_table :file_items do
      column :id,           Integer, serial: true
      column :item_id,      Integer, required: true
      column :url,          String,  required: true
      column :path,         String
      column :md5sum,       String, limit: 32
      column :loaded_at,    DateTime

      column :created_at,   DateTime
      column :updated_at,   DateTime
    end
  end
  down do
    drop_table :file_items
  end
end
