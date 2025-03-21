# name: discourse-skip-email-verification-v11
# about: Skip email verification during user registration (Version 0.11 - Direct Activation in on(:user_created), conditionally)
# version: 0.11
# authors: Your Name/Organization
# url: https://github.com/yourusername/discourse-skip_email_verification-v11
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.11): Email verification skipping is enabled (conditional direct activation in on(:user_created)).")

    # Simplified UserActivator override - Ensure LoginActivator is used
    class ::UserActivator
      alias_method :original_factory, :factory

      def factory
        if !user.active?
          Rails.logger.info("Discourse Skip Email Verification (v0.11 - UserActivator): Using LoginActivator (no skip_email_validation setting here).")
          LoginActivator
        elsif SiteSetting.must_approve_users?
          Rails.logger.info("Discourse Skip Email Verification (v0.11 - UserActivator): Using LoginActivator (even with approval required, no skip_email_validation setting here).")
          LoginActivator
        else
          LoginActivator
        end
      end
    end

    # Direct activation in on(:user_created), conditionally
    on(:user_created) do |user|
      Rails.logger.info("Discourse Skip Email Verification (v0.11 - on(:user_created)): User created, checking skip_email_validation before direct activation.")

      if !user.skip_email_validation
        Rails.logger.info("Discourse Skip Email Verification (v0.11 - on(:user_created)): skip_email_validation is NOT set, attempting direct activation.")
        begin
          user.active = true
          user.approved = true if !SiteSetting.must_approve_users?
          user.save!
          Rails.logger.info("Discourse Skip Email Verification (v0.11 - on(:user_created)): User #{user.id} directly activated in on(:user_created).")
        rescue StandardError => e
          Rails.logger.error("Discourse Skip Email Verification (v0.11 - on(:user_created)): Failed to directly activate user #{user.id} in on(:user_created). Error: #{e.message}")
        end
      else
        Rails.logger.info("Discourse Skip Email Verification (v0.11 - on(:user_created)): skip_email_validation is already set, skipping direct activation.")
      end
    end
  else
    Rails.logger.info("Discourse Skip Email Verification (v0.11): Email verification skipping is disabled.")
  end
end

register_asset "config/settings.yml"
