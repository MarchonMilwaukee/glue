require "googleauth"
require "googleauth/stores/file_token_store"
require "google/apis/gmail_v1"
require "yaml"
require "rmail"

class Gmail 

  def self.messages_for(email_address) 

    credentials = Gmail.credentials()

    gmail = Google::Apis::GmailV1::GmailService.new
    gmail.authorization = credentials

    messages = gmail.list_user_messages('me',
      label_ids: ["Label_1"],
      q: "to:#{email_address}"
    )

    messages

  end

  def self.credentials() 
    config = YAML.load_file("config.yml")

    client_id = Google::Auth::ClientId.new(
      config["gmail"]["client_id"],
      config["gmail"]["client_secret"]
    )
    token_store = Google::Auth::Stores::FileTokenStore.new(:file => "./auth.token")
    authorizer = Google::Auth::UserAuthorizer.new(client_id, "https://mail.google.com/", token_store)

    credentials = authorizer.get_credentials('default')

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      puts url
      code = STDIN.gets.strip
      credentials = authorizer.get_and_store_credentials_from_code(user_id: 'default', code: code, base_url: 'urn:ietf:wg:oauth:2.0:oob')
    end

    credentials
  end

  def self.send!(response) 

    gmail = Google::Apis::GmailV1::GmailService.new
    gmail.authorization = Gmail.credentials()

    message = RMail::Message.new
    message.header['To'] = response.email_address
    message.header['From'] = "mom200nof@gmail.com"
    message.header['Subject'] = "200 Nights of Freedom Event Submission"
    message.header['Content-Type'] = 'text/html'
    message.body = response.email_body()

    msg = gmail.send_user_message('me', upload_source: StringIO.new(message.to_s), content_type: "message/rfc822")
    modify_request = Google::Apis::GmailV1::ModifyMessageRequest.new(add_label_ids: ["Label_1"])
    gmail.modify_message('me', msg.id, modify_request)

  end

end
