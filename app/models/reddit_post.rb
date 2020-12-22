class RedditPost < Base
  UP_VOTES_DEFAULT = 0 
  DOWN_VOTES_DEFAULT = 0
  attr_reader :id, :reddit_id, :reddit_title, :title, :author, :content, :up_votes, :down_votes, :errors

  def initialize(attributes={})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    @reddit_id    = attributes['reddit_id'] if new_record?
    @reddit_title = attributes['reddit_title'] if new_record?
    @author       = attributes['author'] if new_record?
    @id           = attributes['id'] if new_record?
    @title        = attributes['title'] 
    @content      = attributes['content']
    @up_votes     = UP_VOTES_DEFAULT
    @down_votes   = DOWN_VOTES_DEFAULT

    @errors = {}
  end

  def valid?
    @errors['content']  = "Can't be blank" if @content.blank?
    @errors['title']    = "Can't be blank" if @title.blank?
    @errors.empty?
  end

  def insert
    insert_reddit_post_query = <<-SQL
      INSERT INTO reddit_posts (reddit_id, reddit_title, title, author, content, up_votes, down_votes)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    SQL

    connection.execute(insert_reddit_post_query,
      reddit_id,
      reddit_title,
      title,
      author,
      content,
      up_votes,
      down_votes
    )
  end

  def update
    update_reddit_post_query = <<-SQL
      UPDATE reddit_posts 
      SET title   = ?,
          content = ?
      WHERE id = ?
    SQL
    
    connection.execute update_reddit_post_query,
      title, content, id
  end

  def self.find_by_author_and_title(title, author)
    find_by_author_and_title_query = <<-SQL
      SELECT * FROM reddit_posts
      WHERE title = ? AND author = ?
      LIMIT 1
    SQL

    reddit_post_hash = connection.execute(find_by_author_and_title_query, title, author).first
    new(reddit_post_hash)
  end

  def self.find_by_id(id)
    reddit_post_hash = connection.execute("SELECT * FROM reddit_posts WHERE id = ? LIMIT 1", id).first
    new(reddit_post_hash)
  end

  def self.destroy(id)
    connection.execute("DELETE FROM reddit_posts WHERE id = ?", id)
  end

  def comments
    comment_hashes = connection.execute("SELECT * FROM reddit_post_comments WHERE reddit_post_id = ?", @id)
    return [] if comment_hashes == []
    comment_hashes.map { |comment_hash| RedditPostComment.new(comment_hash) }
  end


end