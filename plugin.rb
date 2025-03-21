# name: discourse-skip-email-verification
# about: Skip email verification during user registration (Universal - Direct Signup and Invitations)
# version: 0.7
# authors: thenogodcom
# url: https://github.com/thenogodcom/discourse_skip_email_verification

enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    on(:user_created) do |user|
      # Create the user as normal
      user.active = true
      user.approved = true if !SiteSetting.must_approve_users?
      user.save!

      # Immediately suspend and then activate the user (admin workaround)
      user.suspend(reason: "Skipping email verification (plugin)", duration: 0.1.second)
      user.activate
    end
  end
end

register_asset "config/settings.yml"
