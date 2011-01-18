class UserMailer < ActionMailer::Base
  def signup_notification(user)
#    setup_email(user)
    recipients   user.email
    from         property(:sender_name)
    subject      "#{SITE_NAME}Please activate your new account"
    body :url => "#{SITE_URL}activate/#{user.activation_code}"
    body :user => user
  end
  
  def activation(user)
#    setup_email(user)
    recipients   user.email
    subject 'Your account has been activated'
    body :url => SITE_URL
    body :user => user
  end
 
  def forgot_password(user)
#    setup_email(user)
    recipients   user.email
    subject 'You have requested to change your password'
    body :url => "#{SITE_URL}reset_password/#{user.password_reset_code}"
    body :user => user
  end
  
  def reset_password(user)
#    setup_email(user)
    recipients   user.email
    subject 'Your password has been reset'
    body :user => user
  end

  protected
  def setup_email(user)
    recipients  user.email
    from property(:sender_name)
    body :user => user
  end
end
