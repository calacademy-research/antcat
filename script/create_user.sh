pushd ~/antcat
echo  "User.create! email: 'foozle@strange.org', name: 'joe', can_edit: TRUE, password: 'russack'" | rails console 
popd
