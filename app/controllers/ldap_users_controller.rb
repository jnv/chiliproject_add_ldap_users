# -*- encoding : utf-8 -*-
class LdapUsersController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :require_admin
  accept_key_auth :create

  def new
    @auth_sources = AuthSourceLdap.all
    @users = ''
  end

  def create

    users = []
    unless params[:new_users]
      users = params[:new_users][:users].split(/\W+/) #.reject(&:empty?)
      @auth_source = AuthSourceLdap.find(params[:new_users][:auth_source])
      created = []
      rejected = []
      not_found = []
      duplicate = []
    end

    unless users.empty? or @auth_source.nil?

      begin

        users.each do |login|
          if User.find_by_login(login)
            duplicate << login
            next
          end

          attrs = @auth_source.get_user(login)
          if attrs
            user = User.new(attrs)
            user.login = login
            user.language = Setting.default_language
            if user.save
              created << login
            else
              rejected << "#{login} (#{user.errors.full_messages.join("; ")}"
            end
          else
            not_found << login
          end
        end

      rescue => error
        flash[:error] = error.to_s
      end

      unless created.empty?
        flash[:notice] = l(:ldap_users_created, :count => created.count, :users => created.join(", "))
      end

      unless not_found.empty?
        flash[:warning] = l(:ldap_users_not_found, :count => not_found.count, :users => not_found.join(", "))
      end

      unless duplicate.empty?
        flash[:warning] = l(:ldap_users_duplicated, :count => duplicate.count, :users => duplicate.join(", "))
      end

      unless rejected.empty?
        flash[:error] = l(:ldap_users_rejected, :count => rejected.count, :users => rejected.join("<br />"))
      end

      @users = (users - created).join(' ')
    end
    @auth_sources = AuthSourceLdap.all
    render :action => 'new'

  end

end
