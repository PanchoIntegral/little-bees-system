namespace :admin do
  desc "Create first admin user interactively"
  task create: :environment do
    puts "🔐 Creating your first admin user for Little Bee's POS System"
    puts "=" * 60

    # Check if there are any existing users
    if User.any?
      puts "⚠️  Users already exist in the system:"
      User.all.each do |user|
        puts "   - #{user.email} (#{user.role})"
      end
      print "\nDo you want to continue creating another admin? (y/N): "
      response = STDIN.gets.chomp.downcase
      unless response == 'y' || response == 'yes'
        puts "❌ Admin creation cancelled."
        exit
      end
    end

    puts "\n📝 Please enter the admin user information:"

    # Get email
    print "Email: "
    email = STDIN.gets.chomp
    while email.blank? || !email.match(URI::MailTo::EMAIL_REGEXP)
      print "❌ Please enter a valid email: "
      email = STDIN.gets.chomp
    end

    # Check if email already exists
    if User.exists?(email: email)
      puts "❌ A user with email '#{email}' already exists!"
      exit
    end

    # Get first name
    print "First Name: "
    first_name = STDIN.gets.chomp
    while first_name.blank? || first_name.length < 2
      print "❌ First name must be at least 2 characters: "
      first_name = STDIN.gets.chomp
    end

    # Get last name
    print "Last Name: "
    last_name = STDIN.gets.chomp
    while last_name.blank? || last_name.length < 2
      print "❌ Last name must be at least 2 characters: "
      last_name = STDIN.gets.chomp
    end

    # Get password
    print "Password (minimum 6 characters): "
    password = STDIN.gets.chomp
    while password.blank? || password.length < 6
      print "❌ Password must be at least 6 characters: "
      password = STDIN.gets.chomp
    end

    # Get phone (optional)
    print "Phone (optional): "
    phone = STDIN.gets.chomp
    phone = nil if phone.blank?

    # Ask about 2FA
    print "Enable Two-Factor Authentication? (y/N): "
    two_fa_response = STDIN.gets.chomp.downcase
    two_factor_enabled = two_fa_response == 'y' || two_fa_response == 'yes'

    puts "\n🔨 Creating admin user..."

    begin
      admin = User.create!(
        email: email,
        first_name: first_name,
        last_name: last_name,
        password: password,
        role: 'admin',
        phone: phone,
        two_factor_enabled: two_factor_enabled
      )

      # Setup 2FA if requested
      if two_factor_enabled
        admin.setup_two_factor!
        puts "\n🔐 Two-Factor Authentication has been enabled!"
        puts "📱 QR Code URL: #{admin.generate_qr_code}"
        puts "🔑 Secret Key: #{admin.two_factor_secret}"
        puts "\n📋 Please scan the QR code with your authenticator app"
        puts "   (Google Authenticator, Authy, etc.)"
      end

      puts "\n✅ Admin user created successfully!"
      puts "=" * 60
      puts "📊 User Details:"
      puts "   Email: #{admin.email}"
      puts "   Name: #{admin.full_name}"
      puts "   Role: #{admin.role}"
      puts "   Phone: #{admin.phone || 'Not provided'}"
      puts "   2FA: #{admin.two_factor_enabled? ? 'Enabled' : 'Disabled'}"
      puts "   Created: #{admin.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "=" * 60
      puts "\n🚀 You can now login to the system with these credentials!"

    rescue => e
      puts "❌ Error creating admin user: #{e.message}"
      puts "Please try again with different information."
    end
  end
end