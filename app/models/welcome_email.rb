require_cubeless_engine_file :model, :welcome_email

class WelcomeEmail 
  @@subject = "Welcome to AgentStream!"
  @@content = 
      "<p style='line-height: 24px;'><font color='#004f5a' face='linotype universe, helvetica, arial' size='4'><strong>new-registration</strong></font></p>
       <p style='line-height: 18px;'><font color='#333333' face='linotype universe, helvetica, arial' size='2'>
          Your new account in the world&#39;s largest travel agent-only community is waiting for you!&nbsp;
         <br />
            Below you will find the details of how you can access AgentStream, a secure community where travel professionals around the globe come together to connect and collaborate each day!
         <br />
            Your peers are waiting to meet you and share their knowledge, so why not login and give it a try?
         <br />
            <strong>Find your login ID below, along with a link to set up your new AgentStream password.</strong>
       </font></p>"
end  