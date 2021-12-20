require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    valid_email = 'test@example.com'
    valid_password = 'password'
    post '/auth', params: { value: { email: valid_email, password: valid_password } }
    @token = (JSON.parse @response.body)['token']
    @user = User.find_by(name: 'test_user')
  end

  test 'should be valid' do
    valid_email = 'pow@pow.com'
    valid_password = 'password1234'
    valid_name = 'john1192'
    post '/account/want_to_create', params: { value: { email: valid_email } }
    session = UserCreationSession.find_by(email: valid_email)
    assert session

    post '/users', params: { value: { session_id: session.session_id, password: valid_password, name: valid_name } }

    user = User.find_by(email: valid_email)
    assert user
  end

  test 'should be mine' do
    get '/users/test_user', headers: { Authorization: "Bearer #{@token}" }
    res = JSON.parse @response.body
    assert res['is_my_page'] == true
  end

  test 'should not be mine' do
    get '/users/test_user'
    res = JSON.parse @response.body
    assert_not res['is_my_page']
  end

  test 'should not be mine with token' do
    get '/users/test_user_2', headers: { Authorization: "bearer #{@token}" }
    res = JSON.parse @response.body
    assert_not res['is_my_page']
  end
end
