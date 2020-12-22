class RedditPostComment < Base
  attr_reader :id, :reddit_id, :reddit_post_id, :content, :title, :author, :up_votes, :down_votes, :errors
  UP_VOTES_DEFAULT = 0 
  DOWN_VOTES_DEFAULT = 0

  def initialize(attributes={})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    @id             = attributes['id']
    @reddit_id      = attributes['reddit_id']
    @reddit_post_id = attributes['reddit_post_id']
    @title          = attributes['title']
    @author         = attributes['author']
    @content        = attributes['content']
    @up_votes       = attributes['up_votes']
    @down_votes     = attributes['down_votes']

    @errors = {}
  end

  def valid?
    @errors['content']  = "Can't be blank" if @content.blank?
    @errors['title']    = "Can't be blank" if @title.blank?
    @errors.empty?
  end

  def insert
    insert_reddit_post_comment_query = <<-SQL
      INSERT INTO reddit_post_comments (reddit_id, reddit_post_id, title, author, content, up_votes, down_votes)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    SQL

    connection.execute(insert_reddit_post_comment_query,
      @reddit_id,
      @reddit_post_id,
      @title,
      @author,
      @content,
      UP_VOTES_DEFAULT,
      DOWN_VOTES_DEFAULT
    )
  end

  def update
    update_reddit_post_comment_query = <<-SQL
      UPDATE reddit_post_comments 
      SET content = ?
      WHERE id = ?
    SQL
    
    connection.execute update_reddit_post_comment_query,
      content, id
  end

  def get_reddit_name
    reddit_hash = connection.execute("SELECT * FROM reddits WHERE id = ? LIMIT 1", @reddit_id).first
    reddit = Post.new(reddit_hash)
    reddit.title
  end

  def get_reddit_post
    reddit_post_hash = connection.execute("SELECT * FROM reddit_posts WHERE id = ? LIMIT 1", @reddit_post_id).first
    reddit_post = RedditPost.new(reddit_post_hash)
  end

  def get_reddit_post_author
    get_reddit_post.author
  end

  def get_reddit_post_title
    get_reddit_post.title
  end

  
end
