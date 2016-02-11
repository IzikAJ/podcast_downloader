require 'dm-migrations/migration_runner'

# property :id,          Serial
# property :title,       Text
# property :description, Text
# property :slug,        String, required: true
# property :created_at,  DateTime

migration 0001, :create_cources_table do
  up do
    create_table :sources do
      column :id,          Integer, serial: true
      column :title,       'text'
      column :description, 'text'
      column :slug,        String, required: true

      column :created_at,  DateTime
      column :updated_at,  DateTime
    end
  end
  down do
    drop_table :sources
  end
end
