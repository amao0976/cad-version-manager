Rails.application.configure do
  # 暂时禁用CSP以允许内联脚本
  # config.content_security_policy do |policy|
  #   policy.default_src :self, :https
  #   policy.font_src    :self, :https, :data
  #   policy.img_src     :self, :https, :data
  #   policy.object_src  :none
  #   policy.script_src  :self, :https, :unsafe_inline
  #   policy.style_src   :self, :https, :unsafe_inline
  #   policy.connect_src :self, :https, "ws://localhost", "ws://127.0.0.1"
  #   policy.frame_src   :self, :https
  # end
  #
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w[script-src style-src]
end
