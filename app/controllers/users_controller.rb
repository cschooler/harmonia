class UsersController < ApplicationController
	def show
		@user = User.find(params[:id])
	end

	def index
		@users = User.all
	end

	def new
		@user = User.new
		# Need to add size check before grabbing index 0
		@user.email = params[:email][0]
		@user.first_name = params[:firstName][0]
		@user.last_name = params[:lastName][0]
		@alias = Alias.new
		@alias.alias = params[:alias]
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