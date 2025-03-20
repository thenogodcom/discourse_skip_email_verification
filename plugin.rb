# name: discourse_skip_email_verification
# about: Skip email verification during user registration (Version 0.1 + skip_email_validation)
# version: 0.6 (Version 0.1 + skip_email_validation)
# authors: By INSIINC
# url: https://github.com/yourusername/discourse_skip_email_verification
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.6): Email verification skipping is enabled (Version 0.1 + skip_email_validation).")

    # Override the UserActivator class behavior (from v0.1)
    class ::UserActivator
      alias_method :original_factory, :factory

      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification (v0.6 - UserActivator): Skipping EmailActivator, using LoginActivator with skip_email_validation.")
          DiscourseSkipEmailVerification.activate_user_in_activator(LoginActivator, user) # Use wrapper for skip_email_validation
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification (v0.6 - UserActivator): Skipping ApprovalActivator, using LoginActivator with skip_email_validation.")
          DiscourseSkipEmailVerification.activate_user_in_activator(LoginActivator, user) # Use wrapper for skip_email_validation
        else
          LoginActivator # Default case
        end
      end
    end

    module ::DiscourseSkipEmailVerification
      def self.activate_user_in_activator(activator_class, user) # Wrapper for skip_email_validation in UserActivator
        Rails.logger.info("Discourse Skip Email Verification (v0.6 - UserActivator): Setting skip_email_validation for user #{user.id} in UserActivator.")
        begin
          user.skip_email_validation = true # <--- Added: Use skip_email_validation
          user.save!
          Rails.logger.info("Discourse Skip Email Verification (v0.6 - UserActivator): skip_email_validation set for user #{user.id} in UserActivator.")
        rescue StandardError => e
          Rails.logger.error("Discourse Skip Email Verification (v0.6 - UserActivator): Failed to set skip_email_validation for user #{user.id} in UserActivator. Error: #{e.message}")
          activator_class # Fallback
        else
          activator_class # Return original activator class
        end
      end


      def self.auto_activate_user(user) # From v0.1 - manual activation, kept for on(:user_created) hook
        return if user.nil? || user.active?

        Rails.logger.info("Discourse Skip Email Verification (v0.6 - on(:user_created)): Activating user #{user.id} immediately using manual activation (on(:user_created) hook - v0.1 style).")
        user.active = true # <--- Kept: Manual activation from v0.1
        user.approved = true # <--- Kept: Manual activation from v0.1
        user.save!
      end
    end

    # Hook into user creation to activate immediately (from v0.1)
    on(:user_created) do |user|
      Rails.logger.info("Discourse Skip Email Verification (v0.6): User created (via on(:user_created) hook), attempting manual activation (v0.1 style) for user #{user.id}.")
      DiscourseSkipEmailVerification.auto_activate_user(user)
    end
  else
    Rails.logger.info("Discourse Skip Email Verification (v0.6): Email verification skipping is disabled.")
  end

end

# Add site settings
register_asset "config/settings.yml"
