# -*- encoding : utf-8 -*-
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
  description 'Add new users from LDAP using their username'
  version '0.0.2'
  url 'https://github.com/jnv/chiliproject_add_ldap_users'
  author_url 'https://github.com/jnv'

  menu :admin_menu, :add_ldap_users, {:controller => 'ldap_users', :action => 'new'}, :caption => :label_add_ldap_users
end
