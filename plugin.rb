# name: discourse-skip-email-verification-v08
# about: Skip email verification during user registration (Version 0.8 - Global Activation, including invitations)
# version: 0.8
# authors: Your Name/Organization
# url: https://github.com/yourusername/discourse-skip-email-verification-v08
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.8): Email verification skipping is enabled (attempting global activation).")

    # UserActivator override (from v0.7 - keep this for general flow)
    class ::UserActivator
      alias_method :original_factory, :factory

      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification (v0.8 - UserActivator): Using LoginActivator and skip_email_validation (general flow).")
          DiscourseSkipEmailVerificationV08.activate_user_with_skip_email_validation(LoginActivator, user)
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification (v0.8 - UserActivator): Using LoginActivator (even with approval required) and skip_email_validation (general flow).")
          DiscourseSkipEmailVerificationV08.activate_user_with_skip_email_validation(LoginActivator, user)
        else
          LoginActivator # Default case if already active or no special settings
        end
      end
    end

    module ::DiscourseSkipEmailVerificationV08
      def self.activate_user_with_skip_email_validation(activator_class, user)
        Rails.logger.info("Discourse Skip Email Verification (v0.8 - Activator Helper): Setting skip_email_validation for user #{user.id} (general flow).")
        begin
          user.skip_email_validation = true
          user.save!
          Rails.logger.info("Discourse Skip Email Verification (v0.8 - Activator Helper): skip_email_validation set for user #{user.id}, using #{activator_class} (general flow).")
        rescue StandardError => e
          Rails.logger.error("Discourse Skip Email Verification (v0.8 - Activator Helper): Failed to set skip_email_validation for user #{user.id}. Error: #{e.message} (general flow)")
          activator_class # Fallback to original activator in case of error
        else
          activator_class # Return the chosen activator class (LoginActivator in our case)
        end
      end
    end

    # Global after_auth hook (inspired by discourse-auth-no-email v1.0) - for all registration types including invitations
    on(:after_auth) do |authenticator, result|
      Rails.logger.info("Discourse Skip Email Verification (v0.8 - after_auth): Running after_auth hook to force result.email_valid = true (global activation).")
      result.email_valid = true # Force email to be considered valid - GLOBAL ACTIVATION
      Rails.logger.info("Discourse Skip Email Verification (v0.8 - after_auth): result.email_valid set to true (global activation).")
    end


  else
    Rails.logger.info("Discourse Skip Email Verification (v0.8): Email verification skipping is disabled.")
  end
end

# Add site settings
register_asset "config/settings.yml"
