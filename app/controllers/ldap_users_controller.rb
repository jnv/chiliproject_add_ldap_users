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

    unless users.empty? or @auth_source.nil?

      begin

        users.each do |login|
          next unless User.find_by_login(login).nil?

          attrs = @auth_source.get_user(login)
          if attrs
            user = User.new(attrs)
            user.login = login
            user.language = Setting.default_language
            if user.save
              created << "#{user.name} (#{user.login})"
            else
              rejected << login
            end
          else
            rejected << login
          end
        end

      rescue => error
        flash[:error] = error.to_s
      end

      unless created.empty?
        message = "Users were created: "
        message += created.join(", ")
        flash[:notice] = message
      end

      @users = rejected.join(' ')
    end
    @auth_sources = AuthSourceLdap.all
    render :action => 'new'

  end

end