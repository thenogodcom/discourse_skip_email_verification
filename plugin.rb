# name: discourse_skip_email_verification
# about: Skip email verification during user registration
# version: 0.1
# authors: By INSIINC
# url: https://github.com/yourusername/discourse_skip_email_verification
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification: Email verification skipping is enabled.")

    # Override the UserActivator class behavior
    class ::UserActivator
      alias_method :original_factory, :factory

      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification: Skipping EmailActivator, using LoginActivator.")
          LoginActivator
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification: Skipping ApprovalActivator, using LoginActivator.")
          LoginActivator
        else
          LoginActivator
        end
      end
    end

    # Make sure users are activated immediately
    module ::DiscourseSkipEmailVerification
      def self.auto_activate_user(user)
        return if user.nil? || user.active?

        Rails.logger.info("Discourse Skip Email Verification: Activating user #{user.id} immediately.")
        user.active = true
        user.approved = true
        user.save!
      end
    end

    # Hook into user creation to activate immediately
    on(:user_created) do |user|
      Rails.logger.info("Discourse Skip Email Verification: User created, attempting to activate user #{user.id}.")
      DiscourseSkipEmailVerification.auto_activate_user(user)
    end
  else
    Rails.logger.info("Discourse Skip Email Verification: Email verification skipping is disabled.")
  end

end

# Add site settings
register_asset "config/settings.yml"