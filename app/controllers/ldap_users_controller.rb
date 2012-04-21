class LdapUsersController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :require_admin
  accept_key_auth :create

  def new
    @auth_sources = AuthSourceLdap.all
  end

  def create

    users = params[:user].split(/\W+/) #.reject(&:empty?)
    auth_source = AuthSourceLdap.find(params[:auth_source])

    created = []
    rejected = []

    unless users.empty? || auth_source.nil?

      users.each do |login|
        attrs = auth_source.get_user(login)
        if attrs
          user = User.new(attrs)
          user.login = login
          user.language = Setting.default_language
          if user.save
            user.reload
            created << h(user.name)
          else
            rejected << login
          end
        end
      end

      unless created.empty?
        message = "Users were created:<br />"
        message += created.join("<br />")
        flash[:notice]
      end

      @users = rejected.join(' ')
      @auth_sources = AuthSourceLdap.all
      render :action => 'new'
    end

  end

end