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
      'html' => "50% off<br>first bottle",
      'class' => 'two'
    },
    {
      'count' => 10,
      'html' => '1 free<br>bottle',
      'class' => 'three'
    },
    {
      'count' => 25,
      'html' => '10% off for<br>1 year',
      'class' => 'four'
    },
    {
      'count' => 50,
      'html' => '15% off for<br>1 year',
      'class' => 'five'
    }
  ]

  def add_to_list
    list_id = "ff98cb726d"
    @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
    refer_me = 'http://dose.solutions/?ref=' + self.referral_code
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
