# name: discourse-skip-email-verification
# about: Skip email verification during user registration (direct signup only)
# version: 0.12
# authors: Your Name/Organization
# url: https://github.com/yourusername/discourse-skip_email_verification

enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    on(:user_created) do |user|
      user.active = true
      user.approved = true if !SiteSetting.must_approve_users?
      user.save!
    end
  end
end

register_asset "config/settings.yml"
