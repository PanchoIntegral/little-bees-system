namespace :admin do
  desc "Create a simple admin user with default credentials"
  task create_simple: :environment do
    puts "🔐 Creating default admin user for Little Bee's POS System"
    puts "=" * 60

    # Check if there are any existing users
    if User.any?
      puts "⚠️  Users already exist in the system:"
      User.all.each do |user|
        puts "   - #{user.email} (#{user.role})"
      end
      puts "\n❌ Please clean the database first or use a different email."
      exit
    end

    # Default admin credentials
    admin_data = {
      email: 'admin@littlebees.com',
      first_name: 'Admin',
      last_name: 'User',
      password: 'admin123',
      role: 'admin',
      two_factor_enabled: false
    }

    puts "\n🔨 Creating admin user with default credentials..."
    puts "📧 Email: #{admin_data[:email]}"
    puts "🔑 Password: #{admin_data[:password]}"
    puts "👤 Name: #{admin_data[:first_name]} #{admin_data[:last_name]}"

    begin
      admin = User.create!(admin_data)

      puts "\n✅ Admin user created successfully!"
      puts "=" * 60
      puts "📊 User Details:"
      puts "   Email: #{admin.email}"
      puts "   Name: #{admin.full_name}"
      puts "   Role: #{admin.role}"
      puts "   2FA: #{admin.two_factor_enabled? ? 'Enabled' : 'Disabled'}"
      puts "   Created: #{admin.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "=" * 60
      puts "\n🚀 You can now login to the system with:"
      puts "   Email: #{admin.email}"
      puts "   Password: #{admin_data[:password]}"
      puts "\n💡 Remember to change the password after first login!"

    rescue => e
      puts "❌ Error creating admin user: #{e.message}"
      e.backtrace.each { |line| puts "   #{line}" }
    end
  end

  desc "Create custom admin user with parameters"
  task :create_custom, [:email, :first_name, :last_name, :password] => :environment do |t, args|
    puts "🔐 Creating custom admin user for Little Bee's POS System"
    puts "=" * 60

    # Validate required arguments
    unless args.email && args.first_name && args.last_name && args.password
      puts "❌ Missing required arguments!"
      puts "Usage: rails admin:create_custom[email,first_name,last_name,password]"
      puts "Example: rails admin:create_custom[john@example.com,John,Doe,mypassword123]"
      exit
    end

    # Check if email already exists
    if User.exists?(email: args.email)
      puts "❌ A user with email '#{args.email}' already exists!"
      exit
    end

    admin_data = {
      email: args.email,
      first_name: args.first_name,
      last_name: args.last_name,
      password: args.password,
      role: 'admin',
      two_factor_enabled: false
    }

    puts "\n🔨 Creating admin user..."
    puts "📧 Email: #{admin_data[:email]}"
    puts "👤 Name: #{admin_data[:first_name]} #{admin_data[:last_name]}"

    begin
      admin = User.create!(admin_data)

      puts "\n✅ Admin user created successfully!"
      puts "=" * 60
      puts "📊 User Details:"
      puts "   Email: #{admin.email}"
      puts "   Name: #{admin.full_name}"
      puts "   Role: #{admin.role}"
      puts "   Created: #{admin.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "=" * 60
      puts "\n🚀 You can now login to the system!"

    rescue => e
      puts "❌ Error creating admin user: #{e.message}"
    end
  end
end