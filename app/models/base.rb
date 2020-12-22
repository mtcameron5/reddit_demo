class Base
  
  def new_record?
    @id.blank?
  end

  def save
    return false unless valid?

    new_record? ? insert : update
    true
  end

  def self.connection
    db_connection = SQLite3::Database.new 'db/development.sqlite3'
    db_connection.results_as_hash = true
    db_connection
  end

  def connection
    self.class.connection
  end

end