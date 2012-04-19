class EventsController < ApplicationController
  def index
    @title = 'Events'
    @events = Event.all
  end
  
  def show
    @event = Event.find(params[:id])
    @title = @event.name
  end
  
  def new
    @title = 'Create New Event'
    @event = Event.new
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:success] = "Event Created!"
      redirect_to @event
    else
      @title = "Create New Event"
      render 'new'
    end
  end
end
