require "erb"
require_relative "./gmail"
require_relative "./github"

HOW_I_HELP_QUESTION         = "list_42098940_choice_*"
NAME_QUESTION               = "textfield_41889987"
EMAIL_QUESTION              = "textfield_42591039"
PHONE_NUMBER_QUESTION       = "textfield_42591052"
CONTACT_TIME_QUESTION       = "textfield_41890018"
SKILLS_QUESTION             = "textfield_42099205"
EVENT_NAME_QUESTION         = "textfield_41878046"
EVENT_DESCRIPTION_QUESTION  = "textarea_41878032"
EVENT_AUDIENCE_QUESTION     = "textfield_41890142"
ORGANIZATION_QUESTION       = "textarea_41890067"
EVENT_FIT_QUESTION          = "textarea_41890203"
OTHER_CONTACT_QUESTION      = "textfield_41890211"
EVENT_DATE_QUESTION         = "textfield_41897402"
SPONSORS_QUESTION           = "textfield_41890322"
VENUE_QUESTION              = "textfield_42099383"
SUPPORT_QUESTION            = "list_41897469_choice_*"
KEYWORDS_QUESTION           = "textarea_41890292"
COST_QUESTION               = "textfield_41890672"

IS_EVENT_RESPONSE_TEXT      = "I'd like to submit an event to the calendar"

class Response 

  attr_accessor :id, :answers, :email_address,
    :event_name, :phone_number, :contact_time,
    :organizer_name, :skills, :event_description,
    :event_audience, :organization, :event_fit,
    :other_contacts, :event_date, :sponsors_and_partners,
    :venue, :keywords, :cost, :support_required, :how
    

  def initialize(opts={}) 
    @complete = opts["complete"] == "1"

    @answers = opts["answers"]
    @email_address = @answers[EMAIL_QUESTION]
    @organizer_name = @answers[NAME_QUESTION]
    @phone_number = @answers[PHONE_NUMBER_QUESTION]
    @contact_time = @answers[CONTACT_TIME_QUESTION]
    @skills = @answers[SKILLS_QUESTION]
    @event_name = @answers[EVENT_NAME_QUESTION]
    @event_description = @answers[EVENT_DESCRIPTION_QUESTION]
    @event_audience = @answers[EVENT_AUDIENCE_QUESTION]
    @organization = @answers[ORGANIZATION_QUESTION]
    @event_fit = @answers[EVENT_FIT_QUESTION]
    @other_contacts = @answers[OTHER_CONTACT_QUESTION]
    @event_date = @answers[EVENT_DATE_QUESTION]
    @sponsors_and_partners = @answers[SPONSORS_QUESTION]
    @venue = @answers[VENUE_QUESTION]
    @keywords = @answers[KEYWORDS_QUESTION]
    @cost = @answers[COST_QUESTION]

    @support_required = answers_for(SUPPORT_QUESTION)
    @how = answers_for(HOW_I_HELP_QUESTION)
  end

  def is_new? 
    Gmail.messages_for(@email_address).result_size_estimate == 0
  end

  def is_complete?
    return @complete
  end

  def is_event?
    @how.includes?(IS_EVENT_RESPONSE_TEXT)  
  end

  def send_invite_email! 
    Gmail.send!(self)
  end

  def invite_to_slack!
    puts "[STUB] Send invite to slack"
  end

  def create_github_pull_reqest!
    Github.create_pull_request(
      @event_name, 
      self.event_body, 
      self.pull_request_description
    )
  end

  def event_body() 
    ERB.new(File.read("./templates/markdown.md.erb")).result(binding())
  end

  def pull_request_description()
    "#{@event_name}"
  end

  def answers_for(glob) 
    @answers.keys
      .select{ |key| File.fnmatch(glob, key) }
      .map{ |key| @answers[key].strip }
  end

end
