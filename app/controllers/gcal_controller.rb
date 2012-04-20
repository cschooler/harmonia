require 'rubygems'
require 'google/api_client'
require 'yaml'

class GcalController < ApplicationController
  def index
    oauth_yaml = YAML.load_file('.google-api.yaml')
    client = Google::APIClient.new
    client.authorization.client_id = oauth_yaml["client_id"]
    client.authorization.client_secret = oauth_yaml["client_secret"]
    client.authorization.scope = oauth_yaml["scope"]
    client.authorization.refresh_token = oauth_yaml["refresh_token"]
    client.authorization.access_token = oauth_yaml["access_token"]

    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end

    service = client.discovered_api('calendar', 'v3')
    
    result = client.execute(:api_method => service.events.list, :parameters => {'calendarId' => 'primary', 'timeMin' => '2012-04-01T00:00:00.000Z', 'timeMax' => '2012-05-01T00:00:00.000Z'})
    @events = result.data.items
  end
end
