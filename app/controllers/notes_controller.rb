require_cubeless_engine_file :controller, :notes_controller

class NotesController
  def index
    @profile = current_profile
    @messages = [current_profile.notes, current_profile.sent_notes].flatten.sort_by(&:created_at).reverse
    
    render :layout => "_my_stuff"
  end
  
  def new
    if params[:reply_to]
      @reply = Note.find(params[:reply_to])
      @reply_to_profile = @reply.sender == current_profile ? @reply.receiver : @reply.sender
    end
    
    respond_to do |format|
      format.js { render :partial => '/notes/new', :layout => '/layouts/popup'  }
      format.html { render :partial => '/notes/new', :layout => '/layouts/popup'  }
    end
    
  end
  
  # MM2: Really don't like copying from cubeless engine, but need to change the respond for json
  def create
    Rails.logger.info "CREATING NEW NOTE with params #{params}"
    receiver = find_by_type_and_id(params[:receiver_type], params[:receiver_id])
    note = Note.new(:message => params[:message], :sender => current_profile, :private => params[:private_note], :receiver => receiver)
    if (reply_to_note_id = params[:reply_to_note_id])
      note.receiver = Note.find(reply_to_note_id).sender
      note.replied_to = reply_to_note_id
    end
    note.save!   
    flash[:notice] = "Your message has ben sent."   
    render :text => {:message => "Messsage Sent" }.to_json
    rescue Exception => e
      flash[:errors] = "There was an error sending your message, please try again."
      render :text => {:message => "Unable to save message.", :error => e.message }.to_json
  end
  
  def autocomplete_for_message
    name = params[:q]
    profiles = Profile.exclude_sponsor_members.active.limit(20).find_by_full_name(name)
    # groups = Group.find_by_full_name_and_type(name, [0,1], :limit => 20)
    # results = (profiles + groups).sort{|x,y| x.full_name <=> y.full_name }
    results = profiles.sort{|x,y| x.full_name <=> y.full_name }
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => results}
  end
  
end