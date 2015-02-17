pushd ~/antcat
echo  "User.create! email: 'foozle@strange.org', name: 'joe', can_edit: TRUE, password: 'russack', is_superadmin: '1'" | rails console 
popd
