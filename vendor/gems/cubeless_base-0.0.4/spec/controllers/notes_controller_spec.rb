require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NotesController do
  before(:each) do
    @note = mock_model(Note, :receiver => mock_model(Profile, :notes => [mock_model(Note)]))
    Note.stub!(:find => @note)
  end

  def do_delete
    delete :destroy, :id => 1
  end

  it "should allow admins to delete a note" do
    login_as_shady_admin
    controller.current_profile.stub!(:notes => [])
    @note.stub!(:received_by? => false)
    @note.should_receive(:destroy)
    do_delete
  end

  describe "on a Profile" do
    before(:each) do
      login_as_direct_member
      controller.current_profile.stub!(:notes => [])
    end

    it "should allow the receiver to delete their note" do
      @note.stub!(:received_by? => true)
      @note.should_receive(:destroy)
      do_delete
    end

    it "should not allow anyone but the receiver to delete their note" do
      @note.stub!(:received_by? => false)
      @note.should_not_receive(:destroy)
      do_delete
    end
  end

  describe "on a Group" do
    before(:each) do
      login_as_direct_member
      controller.current_profile.stub!(:notes => [])
    end

    it "should allow group moderators to delete notes" do
      @note.stub!(:receiver => mock_model(Group, :editable_by? => true, :notes => [mock_model(Note)]))
      @note.should_receive(:destroy)
      do_delete
    end

    it "should not allow non group moderators to delete notes" do
      @note.stub!(:receiver => mock_model(Group, :editable_by? => false, :notes => [mock_model(Note)]))
      @note.should_not_receive(:destroy)
      do_delete
    end
  end

end