# If you want the logs displayed you have to do this before the call to setup
# DataMapper::Logger.new($stdout, :debug)

# # An in-memory Sqlite3 connection:
# DataMapper.setup(:default, 'sqlite::memory:')

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, "sqlite://#{App.root}/db/database.db")

# # A MySQL connection:
# DataMapper.setup(:default, 'mysql://user:password@hostname/database')

# # A Postgres connection:
# DataMapper.setup(:default, 'postgres://user:password@hostname/database')

# DataMapper.auto_migrate!
# DataMapper.auto_upgrade!