module SessionsHelper

    # Logs in the given user
    def log_in(user)
        #places a temporary cookie on the user’s browser containing an encrypted version of the user’s id, which allows us to retrieve the id on subsequent pages using session[:user_id]
        session[:user_id] = user.id
    end

    # Remembers a user in a persistent session
    def remember(user)
        # generates the remember token and saves it's digest to the db
        user.remember
        # sets a cookies to expire 20 years from now (.permanent) and securely encrypts it (.signed)
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Logs out the current user
    def log_out
        # Here, current_user is the return value of the current_user method
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    # Returns the current logged-in user (if any)
    def current_user
        if (user_id = session[:user_id])
            #below is the same as @current_user = @current_user || User.find_by(id: session[:user_id]) where the first true result (anything other than nil or false) is assigned to @current_user
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    #Returns true if the user is logged in
    def logged_in?
        !current_user.nil?
    end

end
