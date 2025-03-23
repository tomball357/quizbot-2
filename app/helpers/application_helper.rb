module ApplicationHelper

  def role_color(role)
    case role
    when "user"
      "#007bff" # blue
    when "assistant"
      "#28a745" # green
    when "system"
      "#6c757d" # gray
    else
      "#333"
    end
  end
  
end
