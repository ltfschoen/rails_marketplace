class User < ActiveRecord::Base

  ALLOWED_ROLES = %w(standard admin)

  has_many :listings, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :watched_listings,  -> { uniq }, :through => :watches, dependent: :destroy
  has_many :inquiries
  has_many :messages
  has_many :offers, dependent: :destroy

  # Feedbacks given
  has_many :given_feedbacks_as_seller,
    class_name: 'Feedback',
    foreign_key: :seller_id,
    conditions: { direction: 'seller_to_buyer' }
  has_many :given_feedbacks_as_buyer,
    class_name: 'Feedback',
    foreign_key: :buyer_id,
    conditions: { direction: 'buyer_to_seller' }

  # Feedbacks receieved
  has_many :received_feedbacks_as_seller,
    class_name: 'Feedback',
    foreign_key: :seller_id,
    conditions: { direction: 'seller_to_buyer' }
  has_many :received_feedbacks_as_buyer,
    class_name: 'Feedback',
    foreign_key: :buyer_id,
    conditions: { direction: 'buyer_to_seller' }

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates_inclusion_of :role, in: ALLOWED_ROLES, allow_blank: false

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  def self.search(search)
    where("email ILIKE ?", "%#{search}%") 
  end

  # after_create :send_welcome_mail
  
  # def send_welcome_mail
  #   UserMailer.sign_up_email(self).deliver
  # end

end
