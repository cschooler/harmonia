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
		if(!params[:email].nil?)
			@user.email =  params[:email][0]
		end
		if(!params[:firstName].nil?)
			@user.first_name =  params[:firstName][0]
		end
		if(!params[:lastName].nil?)
			@user.last_name =  params[:lastName][0]
		end
		if(!params[:alias].nil?)
			@alias = Alias.new
			@alias.alias =  params[:alias]
		end
	end

	def create
		@user = User.new(params[:user])
		@user.aliases.build(:alias => params[:alias])

  		if @user.save
    		redirect_to @user, notice: 'User was successfully created.'
  		else
			render action: "new"
  		end
	end
end