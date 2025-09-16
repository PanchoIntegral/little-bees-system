class User < ApplicationRecord
  # Authentication
  has_secure_password
  
  # Associations
  has_many :sales, dependent: :destroy
  
  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[admin manager employee] }
  validates :phone, format: { with: /\A[\+]?[\d\s\-\(\)]+\z/, message: "Invalid phone format" },
            allow_blank: true
  
  # Callbacks
  before_save :normalize_email
  before_save :normalize_phone
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :admins, -> { where(role: 'admin') }
  scope :managers, -> { where(role: 'manager') }
  scope :employees, -> { where(role: 'employee') }
  
  # Two-Factor Authentication
  def setup_two_factor!
    self.two_factor_secret = ROTP::Base32.random
    self.two_factor_enabled = true
    save!
  end
  
  def verify_two_factor(token)
    return false unless two_factor_enabled?
    totp = ROTP::TOTP.new(two_factor_secret)
    totp.verify(token, drift_ahead: 30, drift_behind: 30)
  end
  
  def generate_qr_code
    return nil unless two_factor_secret
    totp = ROTP::TOTP.new(two_factor_secret, issuer: "Little Bee's POS")
    totp.provisioning_uri(email)
  end
  
  # Role checks
  def admin?
    role == 'admin'
  end
  
  def manager?
    role == 'manager'
  end
  
  def employee?
    role == 'employee'
  end
  
  def can_manage_users?
    admin? || manager?
  end
  
  def can_access_reports?
    admin? || manager?
  end
  
  # Display methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def display_name
    full_name
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def normalize_phone
    self.phone = phone.gsub(/[^\d\+]/, '') if phone.present?
  end
end
