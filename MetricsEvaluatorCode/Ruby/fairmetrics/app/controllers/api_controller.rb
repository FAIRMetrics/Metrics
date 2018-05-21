class ApiController < ActionController::API
    include ActionController::MimeResponds
    include ActionController::RequestForgeryProtection
    include ActionDispatch::Flash::RequestMethods
    include ActionView::Rendering
    include ActionView::Layouts
    before_action :authenticate_request
    attr_reader :current_user
    
    include ExceptionHandler
    include SharedFunctions

    # [...]
    private
    def authenticate_request
      @current_user = AuthorizeApiRequest.call(request.headers).result
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
    

    
    
end
