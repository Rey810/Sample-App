class MicropostsController < ApplicationController
    before_action :logged_in_user,  only: [:create, :destroy]
    before_action :correct_user,    only: :destroy

    def create
        # current_user (from the SessionsHelper included in the ApplicationController)
        # strong parameters (micropost_params)
        @micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
            flash[:success] = "Micropost created!"
            redirect_to root_url
        else
            @feed_items = []
            render 'static_pages/home'
        end
    end

    def destroy
        @micropost.destroy
        flash[:success] = "Micropost deleted"
        # request.referrer is the previous URL. Related to request.original_url used in 'friendly-forwarding'
        # redirect_to request.referrer || root_url
        # NEW VERSION (Rails 5):
        redirect_back(fallback_location: root_url)
    end
    
    private 

        def micropost_params
            params.require(:micropost).permit(:content, :picture)
        end

        #checks that the micropost being deleted actually belongs to the current user and what to do if that micropost doesn't actually exist in the db
        def correct_user
            @micropost = current_user.microposts.find_by(id: params[:id])
            redirect_to root_url if @micropost.nil?
        end

end
