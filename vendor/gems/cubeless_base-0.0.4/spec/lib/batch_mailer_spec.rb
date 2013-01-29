require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BatchMailer do
  it "should call the corresponding Notifier method for Group Blog Posts" do
    Notifier.should_receive(:create_group_blog_post)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.mail(mock_model(BlogPost), ["email@email.com"])
  end

  it "should call the corresponding Notifier method for Group Posts" do
    Notifier.should_receive(:create_group_post)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.mail(mock_model(GroupPost), ["email@email.com"])
  end

  it "should call the corresponding Notifier method for Group Notes" do
    Notifier.should_receive(:create_group_note)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.mail(mock_model(Note), ["email@email.com"])
  end

  it "should call the corresponding Notifier method for Group Referrals" do
    Notifier.should_receive(:create_group_referral)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.mail(mock_model(QuestionReferral), ["email@email.com"])
  end

  it "should call the corresponding Notifier method for Shady stuff" do
    Notifier.should_receive(:create_new_abuse)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.mail(mock_model(Abuse), ["admin@email.com"])
  end

  it "should call the corresponding Notifier method for Group Mass Mail" do
    Notifier.should_receive(:create_mass_mail_for_group)
    BatchMailer.should_receive(:batch_me_up_scotty)
    BatchMailer.group_mass_mail(mock_model(Group), mock_model(Profile), "Subject", "body", ["email@email.com"])
  end

end