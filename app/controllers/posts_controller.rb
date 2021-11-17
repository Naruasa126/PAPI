class PostsController < ApplicationController

  def index
    @posts = Post.all
    @all_ranks = Post.find(Favorite.group(:post_id).order('count(post_id) desc').limit(3).pluck(:post_id))
  end

  def new
    @post = Post.new
  end

  def show
    @post = Post.find(params[:id])
    @post_comment = PostComment.new
    @favorite = Favorite.new
  end

  def edit
    @post = Post.find(params[:id])
    unless @post.user == current_user
      redirect_to post_path(@post.id)
    end
  end

  def map
    results = Geocoder.search(params[:address])
    @latlng = results.first.coordinates
    respond_to do |format|
     format.js
    end
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      latitude = params[:post][:map][:latitude]
      longitude = params[:post][:map][:longitude]
      unless latitude.empty? && longitude.empty?
        @map = @post.build_map(
          latitude: latitude,
          longitude: longitude
        )
        @map.save
      end
      redirect_to post_path(@post.id)
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to post_path(@post.id)
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to user_path(current_user)
  end

  private

  def post_params
    params.require(:post).permit(:contents, :image, :user_id, :tag_list, :address,  map_attributes: [:id, :latitude, :longitude])
  end

end
