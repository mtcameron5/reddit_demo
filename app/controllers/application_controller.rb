class ApplicationController < ActionController::Base
  before_action :get_reddits, :check_if_logged_in

  def list_reddits
    reddits = Post.all

    render 'application/reddits/list_reddits', locals: { reddits: reddits }
  end

  def show_reddit
    current_reddit = Post.find_by_title(params['title'])
    reddits = Post.all
    reddit_posts = Post.get_reddit_posts(current_reddit.id)
    new_reddit_post = RedditPost.new

    render 'application/reddits/show_reddit', 
    locals: { current_reddit: current_reddit, reddit_posts: reddit_posts, new_reddit_post: new_reddit_post, 
              reddits: reddits }
  end

  def show_reddit_post
    # binding.pry
    reddit_post = RedditPost.find_by_author_and_title(params['reddit_post_title'], params['author'])
    comments_of_post = reddit_post.comments
    reddit = Post.find(reddit_post.reddit_id)
    render 'application/reddits/show_reddit_post', 
    locals: { reddit_post: reddit_post, reddit: reddit, comments: comments_of_post }
  end

  def create_reddit_post
    current_reddit = Post.find_by_title(params['title'])
    reddit_posts = Post.get_reddit_posts(current_reddit.id)

    new_reddit_post = RedditPost.new(
      'reddit_id'    => current_reddit.id,
      'reddit_title' => current_reddit.title,
      'author'       => session['user_name'],
      'content'      => params['content'],
      'title'        => params['reddit_post_title']
    )

    if new_reddit_post.save
      redirect_to "/reddit/#{params['title']}/#{params['reddit_post_title']}/#{new_reddit_post.author}"
    else
      reddits = Post.all
      render 'application/reddits/show_reddit',
      locals: { current_reddit: current_reddit, reddit_posts: reddit_posts, new_reddit_post: new_reddit_post,
                reddits: reddits }
    end
  end

  def delete_reddit_post
    reddit_post = RedditPost.find_by_id(params['reddit_post_id'])
    reddit = Post.find(reddit_post.reddit_id)
    RedditPost.destroy(params['reddit_post_id'])
    
    redirect_to "/reddit/#{reddit.title}/"
  end

  def edit_reddit_post
    reddit_post = RedditPost.find_by_author_and_title(params['reddit_post_title'], params['author'])
    render 'application/reddits/edit_reddit_post', locals: { reddit_post: reddit_post }
  end

  def update_reddit_post
    reddit_post = RedditPost.find_by_id(params['reddit_post_id'])

    reddit_post.set_attributes(
      'title'   => params['reddit_post_title'],
      'content' => params['content']
    )
    if reddit_post.save
      redirect_to "/reddit/#{reddit_post.reddit_title}/#{reddit_post.title}/#{reddit_post.author}/"
    else
      render 'application/reddits/edit_reddit_post', locals: { reddit_post: reddit_post }
    end
  end

  def list_users
    users = User.all
    render 'application/reddits/list_users', locals: { users: users }
  end

  def create_reddit_post_comment
    new_comment = RedditPostComment.new({
      'author'            => @user_logged_in,
      'title'             => params['comment_title'],
      'content'           => params['content'],
      'reddit_post_id'    => params['reddit_post_id'],
      'reddit_id'         => params['reddit_id']
    })
    new_comment.save

    reddit_post = RedditPost.find_by_id(params['reddit_post_id'])
    reddit = Post.find(params['reddit_id'])
    # comments_of_post = reddit_post.comments
    redirect_to "/reddit/#{reddit.title}/#{reddit_post.title}/#{reddit_post.author}/"
    # locals: { reddit_post: reddit_post, reddit: reddit, comments: comments_of_post }
  end

  def new_user
    new_user = User.new
    render 'application/general/create_user', locals: { new_user: new_user }
  end

  def create_user

    new_user = User.new({
      'username'              => params['user_name'],
      'email_address'         => params['email_address'],
      'password'              => params['password'],
      'password_confirmation' => params['password_confirmation']
    })

    if new_user.save
      session["user_name"] = new_user.user_name
      redirect_to "/user/#{params['user_name']}/"
    else
      render 'application/general/create_user', locals: { new_user: new_user }
    end

  end

  def get_user
    user = User.find_by_username(params['user_name'])
    if user
      reddit_posts = user.posts
      reddit_post_comments = user.comments
      render 'application/user/user_page', 
      locals: { user: user, reddit_posts: reddit_posts, reddit_post_comments: reddit_post_comments }
    else
      render 'application/user/user_does_not_exist_page'
    end
  end

  def login_page
    user_login = User.new
    render 'application/user/login_page', locals: { errors: [] }
  end

  def logout
    session["user_name"] = nil
    redirect_to request.referrer || "/"
  end

  def login
    user, errors = User.login(params['user_name'], params['password'])
    if user
      session["user_name"] = user.user_name
      redirect_to "/user/#{user.user_name}", locals: { user: user }
    else
      render 'application/user/login_page', locals: { errors: errors }
    end
  end

  private 

  def get_reddits
    @reddits = Post.all
  end

  def check_if_logged_in
    @user_logged_in = session['user_name']
  end

end
