# Setup Instructions

## Prerequisites

This project requires the following software installed on macOS:

- Ruby 3.4.x
- Rails 8.x
- PostgreSQL
- Redis
- Sidekiq (OSS)

## Installation Steps

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Ruby 3.4.x

Using `rbenv` (recommended):

```bash
# Install rbenv
brew install rbenv ruby-build

# Add rbenv to your shell
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

rbenv install 3.4.7
rbenv global 3.4.7

# Verify installation
ruby -v  # Should show 3.4.x
```

**Alternative:** Using `asdf`:

```bash
# Install asdf
brew install asdf

# Add asdf to your shell
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.zshrc
source ~/.zshrc

# Install Ruby plugin and Ruby 3.4.0
asdf plugin add ruby
asdf install ruby 3.4.7
asdf global ruby 3.4.7

# Verify installation
ruby -v  # Should show 3.4.x
```

### 3. Install PostgreSQL

```bash
# Install PostgreSQL
brew install postgresql@16

# Start PostgreSQL service
brew services start postgresql@16

# Create a database user (optional, but recommended)
createuser -s disputor

# Verify installation
psql --version
```

**Note:** If you prefer a different PostgreSQL version, you can install `postgresql@15` or `postgresql@14` instead.

### 4. Install Redis

```bash
# Install Redis
brew install redis

# Start Redis service
brew services start redis

# Verify installation
redis-cli ping  # Should return "PONG"
```

### 5. Install Rails 8.x

```bash
# Install Rails 8.x
gem install rails --version "~> 8.0"

# Verify installation
rails -v  # Should show 8.x.x
```

### 6. Install Bundler

```bash
gem install bundler
```

### 7. Clone and Setup the Project

```bash
# Navigate to your project directory
cd /Users/apple/projects/disputor

# Install project dependencies
bundle install

# Setup the database
bin/rails db:create
bin/rails db:migrate
```

### 8. Configure Environment Variables

Create a `.env` file in the project root (or use Rails credentials):

```bash
# .env file
DATABASE_URL=postgresql://localhost/disputor_development
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_secret_key_here
```

**Or use Rails credentials:**

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

### 9. Start the Application

You'll need to run three processes:

**Terminal 1 - Rails Server:**
```bash
bin/rails server
# Server will start on http://localhost:3000
```

**Terminal 2 - Sidekiq Worker:**
```bash
bundle exec sidekiq
# Sidekiq will process background jobs
```

**Terminal 3 - (Optional) Rails Console:**
```bash
bin/rails console
```

### 10. Verify Installation

1. Visit http://localhost:3000 - Rails should be running
2. Check Sidekiq web UI (if configured): http://localhost:3000/sidekiq
3. Verify PostgreSQL connection:
   ```bash
   bin/rails db:migrate:status
   ```
4. Verify Redis connection:
   ```bash
   redis-cli ping
   ```

## Troubleshooting

### Ruby version issues
- Ensure you're using the correct Ruby version: `ruby -v`
- If using rbenv: `rbenv local 3.4.0` in the project directory

### PostgreSQL connection errors
- Check if PostgreSQL is running: `brew services list`
- Verify database exists: `psql -l | grep disputor`
- Check connection: `psql -d disputor_development`

### Redis connection errors
- Check if Redis is running: `brew services list`
- Test connection: `redis-cli ping`

### Sidekiq not processing jobs
- Ensure Redis is running
- Check Sidekiq logs for errors
- Verify REDIS_URL in environment variables

## Quick Start Commands

```bash
# One-time setup(To automate the setup)
bin/setup

# Terminal 1: bin/rails server
# Terminal 2: bundle exec sidekiq

# Run migrations
bin/rails db:migrate

# Create a test user (after implementing)
bin/rails users:create[email@example.com,admin]
```

## Development Tools (Optional)

```bash
# Install useful development tools
brew install git
brew install postgresql@16  # Already installed above
brew install redis          # Already installed above
```
