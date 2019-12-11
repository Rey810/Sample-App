module SessionsHelper

    # Logs in the given user
    def log_in(user)
        #places a temporary cookie on the user’s browser containing an encrypted version of the user’s id, which allows us to retrieve the id on subsequent pages using session[:user_id]
        session[:user_id] = user.id
    end

    # Logs out the current user
    def log_out
        session.delete(:user_id)
        @current_user = nil
    end

    # Returns the current loggin-in user (if any)
    def current_user
        if session[:user_id]
            #below is the same as @current_user = @current_user || User.find_by(id: session[:user_id]) where the first true result (anything other than nil or false) is assigned to @current_user
            @current_user ||= User.find_by(id: session[:user_id])
        end
    end

    #Returns true if the user is logged in
    def logged_in?
        !current_user.nil?
    end

end
