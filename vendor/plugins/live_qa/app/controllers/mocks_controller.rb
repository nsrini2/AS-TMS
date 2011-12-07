class MocksController < ApplicationController
  skip_before_filter :require_auth

  class Entry
    attr_accessor :name, :time, :body, :host
    
    def initialize(name, body, time = Time.now)
      @name = name
      @time = time
      @body = body
      @host = name == "Scott Johnson" ? true : false
    end
    
    def display_name
      host ? "Host - #{abbr_name}" : abbr_name
    end
    
    def abbr_name
      name.split(" ").first + " " + name.split(" ").last.first + "."
    end    
  end

  class Question
    attr_accessor :question, :status, :entries
    
    def initialize(question, status="future")
      @question = question
      @status = status
      
      past_discussion = [  Entry.new("Scott Johnson", "I think this is a good question to get started with."),
                    Entry.new("Scott Johnson", "In the coming months expect to see more graphical improvements, more apps, and some major performance boosts."),
                    Entry.new("Mark McSpadden", "Anything in store for the Mac?"),
                    Entry.new("Claire McSpadden", "What about social media integrations?"),
                    Entry.new("Scott Johnson", "Great questions."),
                    Entry.new("Scott Johnson", "On the Mac, nothing in the 1st half of this year. We are working on some new web capabilities that would be avavailable cross-platform, but they are a ways away."),
                    Entry.new("Scott Johnson", "On the Social Media, we should have some big news coming in Q2...but beyond that I can't discuss any details.")  ]
      present_discussion = [  Entry.new("Scott Johnson", "That's a great question."),
                    Entry.new("Scott Johnson", "There are a few ways to do what you are asking."),
                    Entry.new("Scott Johnson", "First, Log into Sabre Red. Next click 'Help' in the upper right corner"),
                    Entry.new("Scott Johnson", "Then select 'Defaults' and choose the 'View' option"),
                    Entry.new("Scott Johnson", "Under that menu you should find the place to change your default view to graphical view."),
                    Entry.new("Scott Johnson", "Does that make sense?"),
                    Entry.new("Shevawn McSpadden", "It does, but I don't have a 'View' option under 'Defaults'"),
                    Entry.new("Shevawn McSpadden", "I only have 'Connections' and 'Profile'"),
                    Entry.new("Scott Johnson", "Oh...what version of Red Workspace do you have?"),
                    Entry.new("Shevawn McSpadden", "I think it's 1.4"),
                    Entry.new("Scott Johnson", "I'm sorry. Graphical View is only available on 1.5 and up."),
                    Entry.new("Scott Johnson", "Let me send you a message later on how to get upgraded.")  ]
      @entries = (status == "past" ? past_discussion : present_discussion)
    end
  end
  
  class Chat < Struct.new(:name, :start_at, :end_at, :host, :on_air, :attending, :past)
    
    def initialize(*)
      super
      self.on_air ||= false
      self.attending ||= false
      self.past ||= false
    end
    
    def self.all
      [ Chat.new("Sabre Red Workspace", Time.now.advance(:hours => -0.5), Time.now.advance(:hours => 0.5), "Scott Johnson", true),
        Chat.new("The Mock Up Process", Time.now.advance(:hours => 30), Time.now.advance(:hours => 31), "Mark McSpadden"),
        Chat.new("Making your Development Team Happy using Bagels and Other Food Items", Time.now.advance(:hours => 130), Time.now.advance(:hours => 131), "Sarah Kennedy", false, true),
        Chat.new("Crushing employee morale by 'reallocating' resources", Time.now.advance(:hours => 330), Time.now.advance(:hours => 331), "Management"),
        Chat.new("Napkin Oragami", Time.now.advance(:hours => -11), Time.now.advance(:hours => -10), "Joe Dyer", false, false, true) ]
    end
    
  end
  
  def chats
    @chats = Chat.all[0..3]
    @past_chats = Chat.all[4..-1]
  end
  
  def chat
    setup_chat
  end
  def chat_host
    setup_chat
    @host = current_profile
    render :action => "chat"
  end
  def end_chat
    redirect_to "/mocks/chat_done"
  end
  def chat_done
    setup_chat
    @past_questions << @present_question
    @present_question = nil
    @finished = true
    render :action => "chat"
  end

  def new_question
    random_questions = ["What day is it?", "How can I earn extra Sabre points online?", "What is the deal with Sabre and AA? I thought you were friends."]
    
    text =  if params["question"] && !params["question"]["text"].blank?
              params["question"]["text"]
            else
              random_questions.rand
            end
    @question = Question.new(text)
    
    @host = !params["host"].blank?
    if @host
      @fresh = true
    end
    
    if !error_time
      render(:partial => "queue_question", :locals => { :question => @question })
    else
      render :text => "error"
    end
  end
  
  def vote
    up_down = params[:direction]
    @topic = params[:topic_id]
    @profile = Profile.find(params[:profile_id])
    
    # Pratice the error messages on minutes that end in 5
    if error_time
      @errors = ["Error"]
    end
        
    render :text => {"direction" => up_down.titlecase, "errors" => @errors}.to_json
  end
  
  def discuss_question
    @question = Question.new(params[:text])
    @question.entries = []
    render :partial => "present_discussion", :locals => { :question => @question }
  end

  private
  def setup_chat
    @queue_questions = [Question.new("When can we expect the next big release of Sabre Red Workspace?","past"),
                        Question.new("What's the best way to get advanced user training on the new Sabre Red Workspace?","past"), 
                        Question.new("How do I make graphical view my default view in Sabre Red Workspace?","present"), 
                        Question.new("My agency is looking to convert to Sabre. Who do I need to contact to get the ball rolling?"),
                        Question.new("How do I promote cruises on my Facebook page?")]
                        
    @past_questions = @queue_questions.select{ |q| q.status == "past" }
    @present_question = @queue_questions.detect{ |q| q.status == "present" }
    @future_questions = @queue_questions.select{ |q| q.status == "future" }
  end
  
  def error_time
    # Time.now.strftime("%M").to_i%5==0
    # true # For special dev times
    false # For important demos
  end
  
end

