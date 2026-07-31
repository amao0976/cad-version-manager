class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "用户 #{@user.email} 创建成功"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if user_params[:password].present?
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "用户 #{@user.email} 更新成功"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update_without_password(user_params.except(:password, :password_confirmation))
        redirect_to admin_users_path, notice: "用户 #{@user.email} 更新成功"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: '不能删除当前登录的用户'
    else
      @user.destroy
      redirect_to admin_users_path, notice: "用户 #{@user.email} 已删除"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :name, :role, :password, :password_confirmation)
  end
end
