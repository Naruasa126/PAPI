class PostController < ApplicationController

  def index

  end

  def new
    @post = Post.new
  end

  def show

  end

  def edit

  end

  def create
    @post = Post.new(posts_params)
    @post.user_id = current_user.id
    @post.save
    redirect_to
  end

  def update

  end

  def destroy

  end

  private

  def posts_params
    params.require(:post).permit(:contents, :image_id, :user_id, :tag_list, :address, :latitude, :longitude)
  end

end
