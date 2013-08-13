module ApplicationHelper
  def center_button(type='primary',size="lg")

    case type
      when "gray"
        return "btn text-center btn-#{size} btn-default gray_button"
      when "dark_gray"
        return "btn text-center btn-#{size} btn-default dark_gray_button"
      when "dark_red"
        return "btn text-center btn-#{size} btn-default dark_red_button"
      end
    "btn text-center btn-#{size} btn-#{type}"
  end
end
