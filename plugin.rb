# name: discourse-skip-email-verification
# about: Skip email verification during user registration (Universal - Direct Signup and Invitations)
# version: 1.7
# authors: thenogodcom
# url: https://github.com/thenogodcom/discourse_skip_email_verification

enabled_site_setting :skip_email_verification_enabled

after_initialize do
  next unless SiteSetting.skip_email_verification_enabled

  on(:user_created) do |user|
    user.active = true
    user.approved = true unless SiteSetting.must_approve_users?
    user.save!

    if user.staged # For invitations, the token is on the staged user.
      EmailToken.where(user_id: user.id).update_all(confirmed: true)
    else          # For direct signups, we must find the associated EmailToken, if any
      token = EmailToken.find_by(email: user.email)
      if token
          token.confirmed = true
          token.save!
      end
    end
  end
end

register_asset "config/settings.yml"
