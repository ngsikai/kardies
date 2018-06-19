class UserPresenter < BasePresenter
  presents :user

  def online_status
    h.content_tag(:span, "", class: "online-now") if user.is_signed_in?
  end

  def gender_type
    if user.gender == "male"
      h.fa_icon 'male', class: "gender"
    elsif user.gender == "female"
      h.fa_icon 'female', class: "gender female"
    else
      h.fa_icon 'transgender', class: "gender other"
    end
  end

  def new_message
    h.link_to nil, class: "icon-round-message", "data-toggle" => "modal", "data-target" => "#messageModal", "data-username" => "#{user.username}", "data-profile-pic" => "#{user.profile_picture}" do
      h.fa_icon "comment-o"
    end
  end

  def about_info(data)
    if user.send(data).blank?
      no_post
    else
      h.content_tag(:p, h.content_tag(:em, user.send(data)))
    end
  end

  def profile_picture_link(size = :thumb)
    h.link_to h.user_path(user) do
      h.image_tag user.profile_picture(size), class: "icon-size"
    end
  end

  private

  def no_post
    h.content_tag(:p, h.content_tag(:em, "#{h.t 'users.show.no_post'}"), class: "aluminium-text")
  end
end
