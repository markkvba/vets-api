module Types
  class BaseObject < GraphQL::Schema::Object
    def error_details(errors)
      return unless errors

      {
        type: errors&.class,
        message: errors&.message
      }
    end
  end
end
