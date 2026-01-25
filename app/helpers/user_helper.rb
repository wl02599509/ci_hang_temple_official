module UserHelper
  def display_status(user)
    I18n.t("#{user_i18n_path}.statuses.#{user.status}")
  end

  def display_sex(user)
    I18n.t("#{user_i18n_path}.sexes.#{user.sex}")
  end

  def display_zodiac(user)
    return "" if user.zodiac.nil?

    I18n.t("#{user_i18n_path}.zodiacs.#{user.zodiac}")
  end

  private

  def user_i18n_path
    "activerecord.attributes.user"
  end
end
