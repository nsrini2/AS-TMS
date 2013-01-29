class NotesController < ApplicationController

  def show
    redirect_to Note.find(params[:id]).receiver
  end

  def create
    receiver = find_by_type_and_id(params[:receiver_type], params[:receiver_id])
    note = Note.new(:message => params[:message], :sender => current_profile, :private => params[:private_note], :receiver => receiver)
    if (reply_to_note_id = params[:reply_to_note_id])
      note.receiver = Note.find(reply_to_note_id).sender
      note.replied_to = reply_to_note_id
    end
    note.save
    render_for_receiver(receiver)
  end

  def shady
    note = Note.find(params[:id])
    receiver = note.receiver
    Abuse.create!(:reason => params[:abuse][:reason], :profile => current_profile,
                  :owner => note.sender, :abuseable_type => 'Note', :abuseable_id => params[:id])
    render_for_receiver(receiver)
  end

  def destroy
    note = Note.find(params[:id])
    receiver = note.receiver
    note.destroy if (note.receiver.is_a?(Group) ? note.receiver.editable_by?(current_profile) : note.received_by?(current_profile)) || current_profile.has_role?(Role::ShadyAdmin)
    @notes = receiver.notes
    render :template => 'notes/show', :layout => false
  end
  
  # def destroy
  #   msg = Note.find(params[:id])
  #   @notes = msg.receiver.notes
  #   msg.destroy
  #   render :template => 'notes/show', :layout => false
  # end

  protected
  def render_for_receiver(receiver)
    case receiver
      when Profile
        @notes = receiver.notes.allow_profile_or_admin_to_see_all_for_receiver(current_profile, receiver)
      when Group
        @notes = receiver.notes.allow_group_member_or_sender_or_admin_to_see_all_for_receiver(current_profile, receiver)
    end
    render :template => 'notes/show', :layout => false
  end

end