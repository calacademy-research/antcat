pushd ~/antcat
echo  "User.create! email: 'boozle@strange.org', name: 'non-superadmin', can_edit: TRUE, password: 'russack', is_superadmin: '0'" | rails console 
popd
