# name: discourse-skip-email-verification-v10
# about: Skip email verification during user registration (Version 0.10 - Combining on(:user_created) and UserActivator)
# version: 0.10
# authors: Your Name/Organization
# url: https://github.com/yourusername/discourse-skip_email_verification-v10
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.10): Email verification skipping is enabled (combining on(:user_created) and UserActivator).")

    # Simplified UserActivator override (from v0.7/v0.8, simplified)
    class ::UserActivator
      alias_method :original_factory, :factory

      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification (v0.10 - UserActivator): Using LoginActivator and setting skip_email_validation in UserActivator.")
          user.skip_email_validation = true # Set skip_email_validation directly
          LoginActivator
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification (v0.10 - UserActivator): Using LoginActivator (even with approval required) and setting skip_email_validation in UserActivator.")
          user.skip_email_validation = true # Set skip_email_validation directly
          LoginActivator
        else
          LoginActivator # Default case
        end
      end
    end


    # Re-introduce on(:user_created) hook (from v0.1/v0.6) - but using skip_email_validation
    on(:user_created) do |user|
      Rails.logger.info("Discourse Skip Email Verification (v0.10 - on(:user_created)): User created, setting skip_email_validation in on(:user_created) hook.")
      begin
        user.skip_email_validation = true # Set skip_email_validation in on(:user_created) as well
        user.save!
        Rails.logger.info("Discourse Skip Email Verification (v0.10 - on(:user_created)): skip_email_validation set for user #{user.id} in on(:user_created) hook.")
      rescue StandardError => e
        Rails.logger.error("Discourse Skip Email Verification (v0.10 - on(:user_created)): Failed to set skip_email_validation for user #{user.id} in on(:user_created). Error: #{e.message}")
      end
    end


  else
    Rails.logger.info("Discourse Skip Email Verification (v0.10): Email verification skipping is disabled.")
  end
end

# Add site settings
register_asset "config/settings.yml"
