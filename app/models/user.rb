class User < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :reviews
  has_many :social_profiles, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: %i[line google]

  enum gender: { "male": 0, "female": 1, "other": 2 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: { in: 1..30 }       
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6 } ,allow_nil: true
  # validates :address, presence: true, length: { in: 5..60 }
  # validates :gender, presence: true
  validates :nickname, length: { in: 1..30 }, allow_blank: true

  private

  # def self.find_for_google(auth)
  #   user = User.find_by(email: auth.info.email)

  #   unless user
  #     user = User.create(name:     auth.info.name,
  #                        email: auth.info.email,
  #                        provider: auth.provider,
  #                        uid:      auth.uid,
  #                        token:    auth.credentials.token,
  #                        password: Devise.friendly_token[0, 20],
  #                        meta:     auth.to_yaml)
  #   end
  #   user
  # end

 def social_profile(provider)
   social_profiles.select{ |sp| sp.provider == provider.to_s }.first
 end

 def set_values(omniauth)
  return if provider.to_s != omniauth['provider'].to_s || uid != omniauth['uid']
  credentials = omniauth['credentials']
  info = omniauth['info']

  self.access_token = credentials['refresh_token']
  self.access_secret = credentials['secret']
  self.credentials = credentials.to_json
  self.name = info['name']
  self.set_values_by_raw_info(omniauth['extra']['raw_info'])
end

def set_values_by_raw_info(raw_info)
  self.raw_info = raw_info.to_json
  self.save!
end


end