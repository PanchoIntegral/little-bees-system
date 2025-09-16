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
  validates :phone_number, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: "Invalid phone number format" },
            allow_blank: true, uniqueness: true
  validates :password, length: { minimum: 8 }, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"
  }, if: :password_required?

  # Callbacks
  before_save :normalize_email
  before_save :normalize_phone
  before_save :normalize_phone_number
  before_save :set_password_changed_at, if: :will_save_change_to_password_digest?
  before_create :generate_session_token
  after_initialize :set_default_values
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :locked, -> { where.not(locked_at: nil) }
  scope :unlocked, -> { where(locked_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :two_factor_enabled, -> { where(two_factor_enabled: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :admins, -> { where(role: 'admin') }
  scope :managers, -> { where(role: 'manager') }
  scope :employees, -> { where(role: 'employee') }
  
  # Account Lockout and Security
  MAX_FAILED_ATTEMPTS = 5
  LOCKOUT_DURATION = 30.minutes
  PASSWORD_EXPIRY_DAYS = 90

  def increment_failed_attempts!
    self.failed_attempts += 1
    lock_access! if failed_attempts >= MAX_FAILED_ATTEMPTS
    save!
  end

  def reset_failed_attempts!
    update!(failed_attempts: 0, locked_at: nil, unlock_token: nil)
  end

  def lock_access!
    self.locked_at = Time.current
    self.unlock_token = SecureRandom.urlsafe_base64(32)
    save!
  end

  def unlock_access!
    reset_failed_attempts!
  end

  def access_locked?
    locked_at.present? && locked_at > LOCKOUT_DURATION.ago
  end

  def password_expired?
    return false unless password_changed_at
    password_changed_at < PASSWORD_EXPIRY_DAYS.days.ago
  end

  def active_for_authentication?
    active? && !access_locked? && confirmed?
  end

  # Two-Factor Authentication
  def setup_two_factor!
    self.two_factor_secret = ROTP::Base32.random
    self.two_factor_backup_codes = generate_backup_codes.to_json
    self.two_factor_enabled = true
    save!
  end

  def disable_two_factor!
    self.two_factor_enabled = false
    self.two_factor_secret = nil
    self.two_factor_backup_codes = nil
    save!
  end

  def verify_two_factor(token)
    return false unless two_factor_enabled?

    # Check TOTP first
    totp = ROTP::TOTP.new(two_factor_secret)
    if totp.verify(token, drift_ahead: 30, drift_behind: 30)
      return true
    end

    # Check backup codes
    verify_backup_code(token)
  end

  def verify_backup_code(code)
    return false unless two_factor_backup_codes.present?

    codes = JSON.parse(two_factor_backup_codes)
    if codes.include?(code.to_s)
      codes.delete(code.to_s)
      self.two_factor_backup_codes = codes.to_json
      save!
      return true
    end

    false
  end

  def generate_qr_code
    return nil unless two_factor_secret
    totp = ROTP::TOTP.new(two_factor_secret, issuer: "Little Bee's POS")
    totp.provisioning_uri(email)
  end

  def backup_codes
    return [] unless two_factor_backup_codes.present?
    JSON.parse(two_factor_backup_codes)
  end

  def backup_codes_count
    backup_codes.size
  end

  def regenerate_backup_codes!
    self.two_factor_backup_codes = generate_backup_codes.to_json
    save!
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
  
  # Password Reset
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64(32)
    self.reset_password_sent_at = Time.current
    save!
    reset_password_token
  end

  def reset_password_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 2.hours.ago
  end

  def clear_reset_password_token!
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save!
  end

  # Email Confirmation
  def generate_confirmation_token!
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    save!
  end

  def confirm!
    self.confirmed_at = Time.current
    self.confirmation_token = nil
    save!
  end

  def confirmed?
    confirmed_at.present?
  end

  # Session Management
  def regenerate_session_token!
    generate_session_token
    save!
  end

  def invalidate_session!
    self.session_token = nil
    save!
  end

  # SMS Verification Methods
  def generate_sms_verification_code!
    code = sprintf("%06d", rand(999999))
    self.sms_verification_code = code
    self.sms_code_expires_at = 10.minutes.from_now
    save!
    code
  end

  def verify_sms_code(code)
    return false if sms_verification_code.blank?
    return false if sms_code_expires_at.blank? || sms_code_expires_at < Time.current
    return false unless sms_verification_code == code

    # Clear the code after successful verification
    self.sms_verification_code = nil
    self.sms_code_expires_at = nil
    self.phone_verified_at = Time.current
    save!
    true
  end

  def sms_code_expired?
    sms_code_expires_at.blank? || sms_code_expires_at < Time.current
  end

  def phone_verified?
    phone_verified_at.present?
  end

  def send_sms_verification_code
    return { success: false, message: "Phone number required" } if phone_number.blank?

    code = generate_sms_verification_code!
    SmsService.send_verification_code(phone_number, code)
  end

  def enable_sms_verification!
    self.sms_verification_enabled = true
    save!
  end

  def disable_sms_verification!
    self.sms_verification_enabled = false
    self.sms_verification_code = nil
    self.sms_code_expires_at = nil
    save!
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_phone
    self.phone = phone.gsub(/[^\d\+]/, '') if phone.present?
  end

  def normalize_phone_number
    self.phone_number = phone_number.gsub(/[^\d\+]/, '') if phone_number.present?
  end

  def set_password_changed_at
    self.password_changed_at = Time.current
  end

  def generate_session_token
    self.session_token = SecureRandom.urlsafe_base64(32)
  end

  def set_default_values
    self.active = true if active.nil?
    self.failed_attempts = 0 if failed_attempts.nil?
    self.two_factor_enabled = false if two_factor_enabled.nil?
    self.sms_verification_enabled = false if sms_verification_enabled.nil?
    self.must_change_password = false if must_change_password.nil?
  end

  def generate_backup_codes
    Array.new(10) { SecureRandom.hex(4).upcase }
  end

  def password_required?
    new_record? || password.present?
  end
end
