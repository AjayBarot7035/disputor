namespace :users do
  desc "Create a user with specified role (admin, reviewer, or read_only)"
  task :create, [ :email, :password, :role, :time_zone ] => :environment do |_t, args|
    email = args[:email] || ENV["EMAIL"]
    password = args[:password] || ENV["PASSWORD"] || SecureRandom.hex(16)
    role = args[:role] || ENV["ROLE"] || "read_only"
    time_zone = args[:time_zone] || ENV["TIME_ZONE"] || "UTC"

    unless %w[ admin reviewer read_only ].include?(role)
      puts "Error: Role must be one of: admin, reviewer, read_only"
      exit 1
    end

    if email.blank?
      puts "Error: Email is required. Usage: rake users:create[email@example.com,password,admin,UTC]"
      puts "   Or set environment variables: EMAIL=email@example.com PASSWORD=pass ROLE=admin rake users:create"
      exit 1
    end

    user = User.find_or_initialize_by(email: email)
    user.password = password
    user.role = role
    user.time_zone = time_zone

    if user.save
      puts "✓ User created successfully!"
      puts "  Email: #{user.email}"
      puts "  Role: #{user.role}"
      puts "  Time Zone: #{user.time_zone}"
      puts "  Password: #{password}"
    else
      puts "✗ Failed to create user:"
      user.errors.full_messages.each do |message|
        puts "  - #{message}"
      end
      exit 1
    end
  end

  desc "Create sample users (admin, reviewer, read_only)"
  task sample: :environment do
    users = [
      { email: "admin@disputor.local", password: "admin123", role: "admin", time_zone: "UTC" },
      { email: "reviewer@disputor.local", password: "reviewer123", role: "reviewer", time_zone: "America/New_York" },
      { email: "readonly@disputor.local", password: "readonly123", role: "read_only", time_zone: "UTC" }
    ]

    users.each do |user_data|
      user = User.find_or_initialize_by(email: user_data[:email])
      user.password = user_data[:password]
      user.role = user_data[:role]
      user.time_zone = user_data[:time_zone]

      if user.save
        puts "✓ Created #{user_data[:role]}: #{user.email} (password: #{user_data[:password]})"
      else
        puts "✗ Failed to create #{user_data[:email]}: #{user.errors.full_messages.join(', ')}"
      end
    end
  end
end
