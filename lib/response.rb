require_relative "./gmail"


class Response 

  attr_accessor :id, :answers, :email_address

  def initialize(opts={}) 
    @complete = opts["complete"] == "1"
    @email_address = "nick@rokkincat.com"
    self.answers = opts["answers"]
  end

  def is_new? 
    Gmail.messages_for(@email_address).result_size_estimate == 0
  end

  def is_complete?
    return @complete
  end

  def send_invite_email! 
    Gmail.send!(self)
  end

  def invite_to_slack!
    puts "[STUB] Send invite to slack"
  end

  def create_github_pull_reqest!
    puts "[STUB] Post to github"
  end

end
