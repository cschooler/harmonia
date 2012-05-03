require 'pathname'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'openid/store/memory'

class OpenidController < ApplicationController
	def new
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
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/namePerson/friendly', 'friendly', true))
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/namePerson', 'namePerson', true))
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/person/gender', 'gender', true))
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/pref/language', 'language', true))
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/pref/timezone', 'timezone', true))
    fetch_request.add(OpenID::AX::AttrInfo.new('http://axschema.org/media/image/default', 'image', true))
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
      flash[:success] = ("Verification of #{oidresp.display_identifier}"\
                         " succeeded.")
	  fetch_response = OpenID::AX::FetchResponse.from_success_response(oidresp)
    sreg_message = ''
	  fetch_response.data.each {|k,v|
			sreg_message << "<br/><b>#{k}</b>: #{v}"
      }
      flash[:sreg_results] = sreg_message
          
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    else
    end
    redirect_to :action => 'new'
  end
	
	protected
		def openid_consumer
    		if @openid_consumer.nil?
      			store = OpenID::Store::Memory.new
      			@openid_consumer = OpenID::Consumer.new(session, store)
    		end
    		return @openid_consumer
		end
end