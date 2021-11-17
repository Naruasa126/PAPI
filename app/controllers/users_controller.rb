class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @post = @user.posts
  end

  def edit
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to  user_path(current_user)
    end
  end

  def follows
    user = User.find(params[:id])
    @users = user.followings
  end

  def followers
    user = User.find(params[:id])
    @users = user.followers
  end

  def create
    @user = User.new(user_params)
    @user.image = "no_image.jpg"
    if @user.save
      redirect_to posts_path, success: '登録ができました'
    else
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
     redirect_to user_path(@user.id)
    else
     render :edit
    end
  end

  def destroy
  end
  def unsubscribe
    @user = User.find_by(name: params[:name])
  end

  def withdraw
    @user = current_user
    @user.update(is_valid: false)
    reset_session
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :introduction, :image )
  end
end
