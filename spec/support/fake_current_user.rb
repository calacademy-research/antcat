def fake_current_user
  User.current = create(:user)
end
