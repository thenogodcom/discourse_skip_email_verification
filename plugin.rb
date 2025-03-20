# name: discourse_skip_email_verification
# about: Skip email verification during user registration (Improved based on report)
# version: 0.2 (Improved version)
# authors: By INSIINC
# url: https://github.com/yourusername/discourse_skip_email_verification
enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.2): Email verification skipping is enabled.")

    module ::DiscourseSkipEmailVerification
      def self.auto_activate_user(user)
        return if user.nil? || user.active?

        Rails.logger.info("Discourse Skip Email Verification (v0.2): Activating user #{user.id} immediately using user.activate.")
        user.activate  # 使用 user.activate 方法
        user.save!     # 再次保存用户，确保激活状态持久化 (虽然 activate 内部可能已经保存，但显式保存更稳妥)
      end
    end

    # 使用 after_create_user hook
    after_create_user do |user, opts|
      Rails.logger.info("Discourse Skip Email Verification (v0.2): User created (via after_create_user hook), attempting to activate user #{user.id}.")
      DiscourseSkipEmailVerification.auto_activate_user(user)
    end

  else
    Rails.logger.info("Discourse Skip Email Verification (v0.2): Email verification skipping is disabled.")
  end
end

# Add site settings
register_asset "config/settings.yml"
