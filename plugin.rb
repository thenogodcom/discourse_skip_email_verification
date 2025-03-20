# name: discourse_skip_email_verification
# about: Skip email verification during user registration (Improved based on report - on(:user_created) hook)
# version: 0.2.2 (on(:user_created) hook test)
# authors: By INSIINC
# url: https://github.com/yourusername/discourse_skip_email_verification
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.2.2): Email verification skipping is enabled (on(:user_created) hook).")

    module ::DiscourseSkipEmailVerification
      def self.auto_activate_user(user)
        return if user.nil? || user.active?

        Rails.logger.info("Discourse Skip Email Verification (v0.2.2): Activating user #{user.id} immediately using user.activate.")
        begin
          user.activate
          user.save!
          Rails.logger.info("Discourse Skip Email Verification (v0.2.2): User #{user.id} activated successfully.")
        rescue StandardError => e
          Rails.logger.error("Discourse Skip Email Verification (v0.2.2): Failed to activate user #{user.id}. Error: #{e.message}")
        end
      end
    end

    # Use on(:user_created) hook (like version 0.1, but with user.activate)
    on(:user_created) do |user|
      Rails.logger.info("Discourse Skip Email Verification (v0.2.2): User created (via on(:user_created) hook), attempting to activate user #{user.id}.")
      DiscourseSkipEmailVerification.auto_activate_user(user)
    end
  else
    Rails.logger.info("Discourse Skip Email Verification (v0.2.2): Email verification skipping is disabled.")
  end
end

# Add site settings
register_asset "config/settings.yml"
