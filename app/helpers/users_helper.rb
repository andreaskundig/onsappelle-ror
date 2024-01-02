module UsersHelper
    def email_to_code(email)
      email.gsub(/[.@]/, '_')
    end
end
