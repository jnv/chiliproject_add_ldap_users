require 'redmine'
require 'dispatcher'


Dispatcher.to_prepare :add_ldap_users do
  require_dependency 'auth_source_ldap'
  unless AuthSourceLdap.included_modules.include? AddLdapUsers::AuthSourceLdapPatch
    AuthSourceLdap.send(:include, AddLdapUsers::AuthSourceLdapPatch)
  end
end

Redmine::Plugin.register :chiliproject_add_ldap_users do


  name 'Add Users From LDAP'
  author 'Jan Vlnas'
  description 'Add new LDAP users using their username'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :add_ldap_users, {:controller => 'ldap_users', :action => 'new'}, :caption => 'Add LDAP users'
end
