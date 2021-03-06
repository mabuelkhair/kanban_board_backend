require 'test_helper'

class AdminFlowTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create(username:"admin1", password:"123456789", email:"admin@test.com", role: "admin")
    @list = List.create(title: "test list",owner: @admin)
    @card = Card.create(owner: @admin, list: @list, title: "lorem ipsum", description: "lorem ipsum")
    @user =  User.create(username:"user1", password:"123456789", email:"user@test.com")
    @user_list = List.create(title: "test user list",owner: @user)
    # @current_user = users(:admin)
  end
  
  test "admin can login" do
    post "/login",
       params: { password:"123456789", email:"admin@test.com"} 
    assert_response :success
  end

  test "create list" do
    post "/admin/lists", headers:{"Authorization" => login},
       params: { list: {title:"first list"} } 
    assert_response :success

  end
  
  test "create card" do
    params = { card: {title:"first list", description: "card description"} }
    post "/admin/lists/#{@list.id}/cards", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'},
       params:  params.to_json
    assert_response :success
  end
  
  test "create comment on card" do
    params = { comment: {content:"test comment"} }
    post "/admin/lists/#{@list.id}/cards/#{@card.id}/comments", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'},
       params:  params.to_json
    assert_response :success
  end

  test "assign member to list" do
    params = { user_id: @user.id }  
    post "/admin/lists/#{@list.id}/assign_member", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'},
       params:  params.to_json
    assert_response :success
  end

  test "unassign member to list" do
    params = { user_id: @user.id }  
    post "/admin/lists/#{@list.id}/assign_member", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'},
       params:  params.to_json
    assert_response :success  
    delete "/admin/lists/#{@list.id}/unassign_member", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'},
       params:  params.to_json
    assert_response :success
  end

  test "get all lists" do
    get "/admin/lists/", headers:{"Authorization" => login, 'CONTENT_TYPE' => 'application/json'}
    assert_response :success
    lists = JSON.parse @response.body
    assert lists.any? {|list| list['id'] == @user_list.id}


  end

  def login()
    post "/login",
       params: { password:"123456789", email:"admin@test.com"} 
    assert_response :success
    token = (JSON.parse @response.body)["auth_token"]
  end


end