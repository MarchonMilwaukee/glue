require "http"
require "json"
require "yaml"
require_relative "response"
require "octokit"

class Scanner

  def self.run()

    config = YAML.load_file("config.yml")

    Octokit.configure do |c|
      c.login = config["github"]["username"].strip
      c.password = config["github"]["password"].strip
    end

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
      .each(&:create_github_pull_request!)
      .each(&:invite_to_slack!)

  end

  def self.handle_error(error) 
  end

end

