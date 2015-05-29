# trap all exceptions and fail gracefuly with a 500 and a proper message
class ApiErrorHandler < Grape::Middleware::Base
  def call!(env)
    @env = env
    begin
      @app.call(@env)
    rescue Exception => e
      case e.class.name
        when 'Mongoid::Errors::DocumentNotFound'
          error_code = 404
        when 'Mongoid::Errors::Validations', 'Grape::Exceptions::ValidationErrors'
          error_code = 400
        when 'ProductApi::DuplicateKeysError'
          error_code = 403
        else
          error_code = 500
      end
      throw :error, :message => "status: #{error_code}" + ' (' + e.class.name + ') : ' + (e.message || options[:default_message]), :status => error_code
    end
  end

end