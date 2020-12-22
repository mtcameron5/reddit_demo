class Post < Base
  attr_reader :id, :title

  def initialize(attributes={})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    @id = attributes['id']
    @title = attributes['reddit_name']
  end

  def self.get_reddit_posts(id)
    reddit_post_hashes = connection.execute("SELECT * FROM reddit_posts WHERE reddit_id = ?", id)
    reddit_post_hashes.map { |reddit_post_hash| RedditPost.new(reddit_post_hash) }
  end

  def self.all
    reddit_hashes = connection.execute('SELECT * FROM reddits')
    reddit_hashes.map { |reddit_hash| Post.new(reddit_hash) }
  end
  
  def self.find(id)
    reddit_hash = connection.execute("SELECT * FROM reddits WHERE id = ? LIMIT 1", id).first
    new(reddit_hash)
  end

  def self.find_by_title(title)
    reddit_hash = connection.execute("SELECT * FROM reddits WHERE reddit_name = ? LIMIT 1", title).first
    new(reddit_hash)
  end

end