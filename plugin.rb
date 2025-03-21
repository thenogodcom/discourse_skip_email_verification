# name: discourse_skip_email_verification_combined
# about: Skip email verification during user registration and ensure immediate activation
# version: 8.0
# authors: By INSIINC, Improved
# url: https://github.com/yourusername/discourse_skip_email_verification_combined
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification Combined: Email verification skipping is enabled.")

    # Override the UserActivator class behavior to skip email activation
    class ::UserActivator
      alias_method :original_factory, :factory
      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification Combined: Skipping EmailActivator, using LoginActivator.")
          LoginActivator
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification Combined: Skipping ApprovalActivator, using LoginActivator.")
          LoginActivator
        else
          LoginActivator
        end
      end
    end

    # Module for activation logic
    module ::DiscourseSkipEmailVerification
      def self.activate_user(user)
        return if user.nil? || user.active?

        Rails.logger.info("Discourse Skip Email Verification Combined: Activating user #{user.id} immediately.")
        user.active = true
        user.approved = true
        user.save!

        # Log activation (optional)
        Rails.logger.info("Discourse Skip Email Verification Combined: User #{user.id} has been activated.")
      end
    end

    # Ensure users are immediately activated and approved
    on(:user_created) do |user|
      DiscourseSkipEmailVerification.activate_user(user)
    end

  else
    Rails.logger.info("Discourse Skip Email Verification Combined: Email verification skipping is disabled.")
  end
end

# Add site settings
register_asset "config/settings.yml"
