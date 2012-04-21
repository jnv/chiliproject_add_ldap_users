class LdapUsersController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :require_admin
  accept_key_auth :create

  def new
    @auth_sources = AuthSourceLdap.all
  end

  def create

    users = params[:new_users][:users].split(/\W+/) #.reject(&:empty?)
    @auth_source = AuthSourceLdap.find(params[:new_users][:auth_source])

    created = []
    rejected = []
    not_found = []
    duplicate = []

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
              created << "#{user.name} (#{user.login})"
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
        flash[:notice] = "Users were created: #{created.join(", ")}"
      end

      unless not_found.empty?
        flash[:warning] = "Users not found in LDAP: #{not_found.join(", ")}"
      end

      unless duplicate.empty?
        flash[:warning] = "Users already present in database: #{duplicate.join(", ")}"
      end

      unless rejected.empty?
        flash[:error] = "Could not process users: #{rejected.join("<br />")}"
      end

      @users = (not_found | rejected).join(' ')
    end
    @auth_sources = AuthSourceLdap.all
    render :action => 'new'

  end

end