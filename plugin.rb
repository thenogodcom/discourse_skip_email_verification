# name: discourse-skip-email-verification-v15
# about: Skip email verification during user registration (Version 0.15 - Targeting InviteRedeemer)
# version: 0.15
# authors: Your Name/Organization
# url: https://github.com/yourusername/discourse-skip_email_verification

enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    Rails.logger.info("Discourse Skip Email Verification (v0.15): Email verification skipping enabled - Targeting InviteRedeemer.")

    # Patch InviteRedeemer to bypass via_email check and force activation for all invites
    module ::InviteRedeemer

      prepend(Module.new do
        def create_user_from_invite(
          email:,
          invite:,
          username:,
          name:,
          password:,
          user_custom_fields:,
          ip_address:,
          session:,
          email_token:
        )
          user = super(
            email: email,
            invite: invite,
            username: username,
            name: name,
            password: password,
            user_custom_fields: user_custom_fields,
            ip_address: ip_address,
            session: session,
            email_token: email_token
          )

          Rails.logger.info("Discourse Skip Email Verification (v0.15 - InviteRedeemer Patch): Force activating user #{user.id} regardless of invite type.")
          user.activate # Force activate user - bypass via_email check
          Rails.logger.info("Discourse Skip Email Verification (v0.15 - InviteRedeemer Patch): User #{user.id} force activated.")
          user # Return the user

        end
      end)
    end


  else
    Rails.logger.info("Discourse Skip Email Verification (v0.15): Email verification skipping is disabled.")
  end
end

register_asset "config/settings.yml"
