ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

module SignInHelper
  def sign_in_as(user)
    post user_session_path, params: {
      user: { email: user.email, password: user.password || "password123" }
    }
  end
end

ActionDispatch::IntegrationTest.include SignInHelper
