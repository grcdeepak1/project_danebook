class UsersController < ApplicationController
  before_action :set_user_and_profile, only: [:about, :timeline]
  skip_before_action :require_login, only: [:new, :create, :show]

  def new
    if signed_in_user?
      redirect_to about_user_path(current_user)
    else
      @user = User.new
    end
  end

  def show

  end

  def create
    @user = User.new(user_params)
    if @user.save
      permanent_sign_in(@user)
      flash[:success] = "You've successfully signed up"
      redirect_to about_user_path(@user)
    else
      flash.now[:danger] = "Please correct errors and resubmit the form"
      render :new
    end
  end

  def about
    @user = User.find(params[:id])
    if @user == current_user
      @friendship_id = nil
    else
      @friendship_id = Friendship.find_by(initiator: current_user.id, recipient:  @user.id)
    end
    @friendship = Friendship.new
  end

  def timeline
    @post = Post.new
    @comment = Comment.new
    @posts = Post.includes(:user, :likes, :comments => [:author, :likes]).order(created_at: :desc)
    @user = User.find(params[:id])
    @friends = @user.initiated_friends
  end

  def friends
    @user = User.includes(:initiated_friends).find(params[:id])
    @friends = @user.initiated_friends
  end

  private

  def set_user_and_profile
    @user =  User.includes(:profile).find(params[:id])
    @profile = @user.profile
  end

  def user_params
      params.require(:user).permit(:first_name, :last_name, :email,
                                   :password, :password_confirmation,
                                   :birthday, :gender_cd)
  end


end
