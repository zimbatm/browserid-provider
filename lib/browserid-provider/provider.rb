require 'erb'

module BrowserID

  # The BrowserID Provider Rack App
#match ".well-known/:action" => 'verified_emails'
#get "provision(/:email(/:duration))" => 'verified_emails#provision'
#get "whoami" => 'verified_emails#whoami'
#post "certify" => 'verified_emails#certify'
  # Default paths are:
  #  GET  /.well-known/browserid
  #  GET  /whoami
  #  GET  /provision
  #  POST /certify
  class Provider
    attr_accessor :config

    def initialize(app = nil, options = {})
      @app, @config = app, BrowserID::Config.new(options)
    end

    # Rack enabled!
    def call(env)
      @path = env["PATH_INFO"]

      # Return Not found or send call back to middleware stack unless the URL is captured here
      return (@app ? @app.call(env) : not_found) unless @config.urls.include? @path

      case @path
        when config.whoami_path do
          current_user = eval config.whoami
          [
            200,
            {"Content-Type" => "text/html"},
            [{ user: current_user ? current_user.email.sub(/@.*/,'') : nil }.to_json]
          ]
        end
        else not_found
      end
    end

    private

    def not_found
          debugger
      template = ERB.new File.read("../../vendor/browserid/templates/404.html.erb")
      [404, {"Content-Type" => "text/html"}, template.result]
    end

  end
end
