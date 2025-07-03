# Production Setup Guide

## Environment Variables Required

Add these environment variables to your production server:

```bash
# Application Configuration
HOST=polishmygame.com

# Email Configuration (SendGrid)
SENDGRID_API_KEY=your_sendgrid_api_key_here
MAILER_FROM=noreply@polishmygame.com

# Rails Configuration
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_here
RAILS_LOG_LEVEL=info

# Database (if using external database)
DATABASE_URL=your_database_url_here

# Other services
OPENAI_API_KEY=your_openai_api_key_here
```

## SendGrid Setup

1. **Create a SendGrid account** at https://sendgrid.com
2. **Get your API key**:
   - Go to Settings → API Keys
   - Create a new API key with "Mail Send" permissions
   - Copy the API key

3. **Verify your sender domain** (optional but recommended):
   - Go to Settings → Sender Authentication
   - Follow the domain authentication process
   - This improves email deliverability

4. **Set the environment variable**:
   ```bash
   SENDGRID_API_KEY=SG.your_actual_api_key_here
   ```

## Email Testing

To test the email functionality in production:

1. Navigate to any game analysis
2. Go through the steps until you reach step 3
3. Fill out the contact form
4. Submit - you should receive an email at keyvan.games@pm.me

## Alternative Email Services

If you prefer not to use SendGrid, you can use:

### Mailgun
```ruby
# In config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.mailgun.org',
  port: 587,
  domain: 'your-domain.com',
  user_name: ENV['MAILGUN_USERNAME'],
  password: ENV['MAILGUN_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

### Gmail SMTP
```ruby
# In config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'your-domain.com',
  user_name: ENV['GMAIL_USERNAME'],
  password: ENV['GMAIL_APP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## Deployment Checklist

- [ ] Set all environment variables
- [ ] Configure SendGrid API key
- [ ] Test email functionality
- [ ] Verify domain in SendGrid (optional)
- [ ] Monitor email delivery logs 