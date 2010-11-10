require_cubeless_engine_file :controller, :notes_controller

class NotesController
  
  def new
    if params[:reply_to]
      @reply = Note.find(params[:reply_to])
      @reply_to_profile = @reply.sender == current_profile ? @reply.receiver : @reply.sender
    end
    
    respond_to do |format|
      format.js { render :layout=> 'layouts/_popup' }
    end
  end
  
  # MM2: Really don't like copying from cubeless engine, but need to change the respond for json
  def create
    receiver = find_by_type_and_id(params[:receiver_type], params[:receiver_id])
    note = Note.new(:message => params[:message], :sender => current_profile, :private => params[:private_note], :receiver => receiver)
    if (reply_to_note_id = params[:reply_to_note_id])
      note.receiver = Note.find(reply_to_note_id).sender
      note.replied_to = reply_to_note_id
    end
    note.save
    # render_for_receiver(receiver)
    
    render :text => {:errors => [] }.to_json
  end
  
  def autocomplete_for_message
    name = params[:q]
    profiles = Profile.exclude_sponsor_members.find_by_full_name(name, :status => :active, :limit => 20)
    # groups = Group.find_by_full_name_and_type(name, [0,1], :limit => 20)
    # results = (profiles + groups).sort{|x,y| x.full_name <=> y.full_name }
    results = profiles.sort{|x,y| x.full_name <=> y.full_name }
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => results}
  end
  
end