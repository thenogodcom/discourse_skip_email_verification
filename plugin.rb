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
      # Convert minutes to seconds for duration.  Handle potential nil/invalid values.
      suspend_duration_minutes = SiteSetting.skip_email_verification_suspend_duration
      suspend_duration_seconds = if suspend_duration_minutes.is_a?(Numeric) && suspend_duration_minutes >= 0
                                   suspend_duration_minutes * 60
                                 else
                                   60  # Default to 60 seconds (1 minute) if invalid
                                 end
      user.suspend(reason: "Skipping email verification (plugin)", duration: suspend_duration_seconds.seconds)
      user.activate
    end
  end
end

register_asset "stylesheets/common/skip-email-verification.scss"
register_asset "config/settings.yml"
