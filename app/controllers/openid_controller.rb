require 'pathname'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'openid/store/filesystem'

class OpenidController < ApplicationController
	def index
	end

	def view
		#TODO: show a form requesting the user's OpenID
	end
	
	def create
		begin
		  identifier = params[:openid_url]
		  if identifier.nil?
			flash[:error] = "Enter an OpenID identifier"
			redirect_to :action => 'index'
			return
		  end
		  oidreq = openid_consumer.begin(identifier)
		rescue OpenID::OpenIDError => e
		  flash[:error] = "Discovery failed for #{identifier}: #{e}"
		  redirect_to :action => 'index'
		  return
		end
		fetch_request = OpenID::AX::FetchRequest.new
		
		fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/namePerson/first', 'first', true))
    	fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/namePerson/last', 'last', true))
    	fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/contact/email', 'email', true))
		oidreq.add_extension(fetch_request)
		
		return_to = url_for :action => 'complete', :only_path => false
		realm = url_for root_url
		
		if oidreq.send_redirect?(realm, return_to, params[:immediate])
		  redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
		else
		  render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
		end
	end
	
	def complete
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    parameters.delete :controller
    parameters.delete :action
    oidresp = openid_consumer.complete(parameters, current_url)
    case oidresp.status
    when OpenID::Consumer::FAILURE
      if oidresp.display_identifier
        flash[:error] = ("Verification of #{oidresp.display_identifier}"\
                         " failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
    when OpenID::Consumer::SUCCESS
	  fetch_response = OpenID::AX::FetchResponse.from_success_response(oidresp)
    sreg_message = ''
    email = fetch_response.data['http://axschema.org/contact/email'];
    first_name = fetch_response.data['http://axschema.org/namePerson/first']
    last_name = fetch_response.data['http://axschema.org/namePerson/last']
    openid_display = oidresp.display_identifier
          
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    else
    end
    redirect_to :action => 'new', :controller => 'users', :email => email, :firstName => first_name, :lastName => last_name, :alias => openid_display
  end
	
	protected
		def openid_consumer
    		if @openid_consumer.nil?
      			store = OpenID::Store::Filesystem.new('./')
      			@openid_consumer = OpenID::Consumer.new(session, store)
    		end
    		return @openid_consumer
		end
end