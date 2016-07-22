require 'users_helper'

class User < ActiveRecord::Base
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'

  validates :email, presence: true, uniqueness: true, format: {
    with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i,
    message: 'Invalid email format.'
  }
  validates :referral_code, uniqueness: true

  before_create :create_referral_code
  before_create :add_to_list
  after_create :send_welcome_email

  REFERRAL_STEPS = [
    {
      'count' => 5,
      'html' => 'Dose shaker<br>bottle',
      'class' => 'two'
    },
    {
      'count' => 10,
      'html' => '1 bottle<br>A8',
      'class' => 'three'
    },
    {
      'count' => 25,
      'html' => 'DOSE Baseball<br>hat',
      'class' => 'four'
    },
    {
      'count' => 50,
      'html' => 'One Year 15%<br>discount on A8',
      'class' => 'five'
    }
  ]

  def add_to_list
    list_id = "ff98cb726d"
    @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
    refer_me = 'http://dose-a8.herokuapp.com/?ref=' + self.referral_code
    subscribe = @gb.lists(list_id).members.create(body: {
      email_address: self.email,
      status: 'subscribed',
      double_optin: false,
      merge_fields: { REFERRAL_E: refer_me}
      })
  end

  private

  def create_referral_code
    self.referral_code = UsersHelper.unused_referral_code
  end

  def send_welcome_email
    # UserMailer.delay.signup_email(self)
  end
end
