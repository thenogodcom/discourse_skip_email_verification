# name: disable-discourse-email-verification
# about: Disable email verification during registration
# version: 0.1.0
# authors: Your Name
# url: https://github.com/yourusername/disable-discourse-email-verification

enabled_site_setting :disable_email_verification_enabled

after_initialize do
  module ::DisableEmailVerification
    class Engine < ::Rails::Engine
      engine_name "disable_email_verification"
      isolate_namespace DisableEmailVerification
    end
  end

  # 覆盖用户激活方法
  User.class_eval do
    def activate
      if SiteSetting.disable_email_verification_enabled
        # 直接激活用户，跳过邮箱验证
        self.active = true
        self.approved = true
        self.email_confirmed? ? nil : self.confirm_email
        save
      else
        super
      end
    end
  end
end
