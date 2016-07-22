class UserMailer < ActionMailer::Base
  default from: "Harry's <welcome@harrys.com>"

  def signup_email(user)
    @user = user
    @twitter_message = "A8 is upgrading nutrition. Didn’t want to leave you all behind. Check out A8 here."

    mail(:to => user.email, :subject => "Thanks for signing up!")
  end
end
