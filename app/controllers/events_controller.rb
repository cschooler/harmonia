class EventsController < ApplicationController
  def index
    @title = 'Events'
  end
  
  def show
    @title = 'Event'
  end
  
  def new
    @title = 'Create New Event'
  end
  
  def create
    
  end
end
