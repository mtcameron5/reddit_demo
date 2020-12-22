class User < Base
  attr_reader :user_name, :email_address, :password, :password_confirmation, :posts, :errors,
              :post_upvotes, :post_downvotes, :admin, :comments, :login_errors

  def initialize(attributes={})
    set_attributes(attributes)
  end

  def set_attributes(attributes)
    @user_name = attributes['username']
    @email_address = attributes['email_address']
    @password = attributes['password']
    @password_confirmation = attributes['password_confirmation']
    @posts = attributes['posts']
    @comments = attributes['comments']
    @errors = []
    @login_errors = []
  end

  def new_record?
    @id.blank?
  end

  def valid?

    if user_name_exists?
      @errors << "User name is taken."
    end

    if email_address_exists?(@email_address)
      @errors << "Email address is taken."
    end
    
    if @user_name.nil? || @user_name.length < 3
      @errors << "User name must have at least 3 characters"
    end

    if @password_confirmation != @password
      @errors << "Password and Password Confirmation do not match"
    end

    if @password.length < 6 || @password_confirmation.length < 6
      @errors <<  "Password must be of length 6 or greater"
    end

    @errors.empty?
  end

  def save
    return false unless valid?

    new_record? ? insert : update

    true
  end

  def is_admin?
    @admin == true || @admin == 1
  end
  
  def insert
    insert_user_query = <<-SQL
      INSERT INTO users (username, email_address, password, password_confirmation)
      VALUES (?, ?, ?, ?)
    SQL


    connection.execute(insert_user_query,
      user_name.downcase,
      email_address,
      password,
      password_confirmation,
    )    

  end

  def update
  end

  def email_address_exists?(email)
     users = User.all
     email_addresses = users.map { |user| user.email_address.downcase }
     email_addresses.include?(email.downcase)
  end

  def self.user_name_exists?(user_name)
    return false if user_name.nil? || user_name.blank?
    users = User.all
    user_names = users.map { |user| user.user_name }
    user_names.include?(user_name.downcase)
  end

  def user_name_exists?
    self.class.user_name_exists?(self.user_name)
  end

  def self.login(user_name, password)
    user_name = user_name.downcase
    login_errors = []
    if user_name_exists?(user_name)
      user = User.find_by_username(user_name)
      if user.password == password
        return user, nil
      else
        login_errors << 'Password incorrect.'
      end
    else
      login_errors << 'User not found.'
    end

    return nil, login_errors
  end

  def self.find_by_username(user_name)
    user = connection.execute("SELECT * FROM users WHERE username = ? LIMIT 1", user_name.downcase).first 
    new(user)
  end

  def self.all
    users_hashes = connection.execute("SELECT * FROM users")
    users_hashes.map { |users_hash| new(users_hash) }
  end

  def posts
    reddit_posts_hashes = connection.execute("SELECT * FROM reddit_posts WHERE author = ?", user_name)
    return [] if reddit_posts_hashes == []
    reddit_posts_hashes.map { |reddit_posts_hashes| RedditPost.new(reddit_posts_hashes) } 
  end

  def comments
    comment_hashes = connection.execute("SELECT * FROM reddit_post_comments WHERE author = ?", user_name)
    return [] if comment_hashes == []
    comment_hashes.map { |comment_hash| RedditPostComment.new(comment_hash) }
  end

end
