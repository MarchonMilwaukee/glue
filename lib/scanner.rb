require "http"
require "json"
require "yaml"
require_relative "response"

class Scanner

  def self.run()
    config = YAML.load_file("config.yml")
    url = "https://api.typeform.com/v1/form/#{config["typeform"]["form_id"]}?key=#{config["typeform"]["api_key"]}"
    resp = HTTP.get(url)    

    # If valid, process the responses
    case resp.status 
    when 200
      Scanner.process(JSON.parse(resp.body)["responses"])
    else
      Scanner.handle_error(resp.body)
    end
  end

  def self.process(responses)

    # Fetch all of the complete responses
    # and select the ones who have been completed
    # since the last scan. Send them an email
    # and invite them to slack
    responses.map { |r| Response.new(r) }
      .select(&:is_complete?)
      .select(&:is_new?)
      .each(&:send_invite_email!)
      .each(&:invite_to_slack!)

  end

  def self.handle_error(error) 
  end

end

