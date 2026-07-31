class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :translate_inspection_type, :supplier_user?, :qc_user?, :admin_user?, :editor?

  def require_admin
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: '您没有权限执行此操作'
    end
  end

  def translate_inspection_type(type)
    return '' if type.blank?
    I18n.t("enums.inspection_type.#{type}", default: type)
  end

  def supplier_user?
    user_signed_in? && current_user.respond_to?(:role) && current_user.role == 'supplier'
  end

  def qc_user?
    user_signed_in? && current_user.respond_to?(:role) && current_user.role == 'qc'
  end

  def admin_user?
    user_signed_in? && current_user.respond_to?(:role) && current_user.role == 'admin'
  end

  def editor?
    user_signed_in? && current_user.respond_to?(:role) && ['admin', 'manager', 'engineer'].include?(current_user.role)
  end
end