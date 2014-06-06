class UserMailer < ActionMailer::Base
  default from: "ben.kennedy@project-turntable.com"

  def registration_confirmation(user)
    if user.email
      mail(:to => user.email, :subject => "Registered")
    end
  end


end
