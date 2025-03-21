# name: discourse-skip-email-verification
# about: Skip email verification during user registration (Universal - Direct Signup and Invitations)
# version: 1.7
# authors: thenogodcom
# url: https://github.com/thenogodcom/discourse_skip_email_verification

enabled_site_setting :skip_email_verification_enabled

after_initialize do
  if SiteSetting.skip_email_verification_enabled
    on(:user_created) do |user|
      user.active = true
      user.approved = true if !SiteSetting.must_approve_users?
      user.save!
    end

    class ::InvitesController # <--- Corrected to class ::InvitesController
      prepend(Module.new do
        def send_activation_email(user)
          # Do nothing - block activation emails for invites
        end
      end)
    end
  end
end

register_asset "config/settings.yml"
