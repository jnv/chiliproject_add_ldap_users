# -*- encoding : utf-8 -*-
module AddLdapUsers
  module AuthSourceLdapPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def get_user(login)
        return nil if login.blank?
        attrs = get_user_dn(login)

        if attrs && attrs[:dn]
          logger.debug "Found user '#{login}'" if logger && logger.debug?
          return attrs.except(:dn)
        end
      rescue Net::LDAP::LdapError => text
        raise "LdapError: " + text.to_s
      end

    end
  end

end