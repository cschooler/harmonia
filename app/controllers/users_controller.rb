class UsersController < ApplicationController
	skip_before_filter :require_login, :only => [:new, :create]

	def show
		@user = User.find(params[:id])
	end

	def index
		@users = User.all
	end

	def new
		@user = User.new
		@user.email =  params[:email]
		@user.first_name =  params[:firstName]
		@user.last_name =  params[:lastName]
		if(!params[:alias].nil?)
			@alias = Alias.new
			@alias.alias =  params[:alias]
		end
	end

	def create
		@user = User.new(params[:user])
		@user.aliases.build(:alias => params[:alias])

  		if @user.save
  			session[:current_user_id] = @user.id
    		redirect_to @user, notice: 'User was successfully created.'
  		else
			render action: "new"
  		end
	end
end