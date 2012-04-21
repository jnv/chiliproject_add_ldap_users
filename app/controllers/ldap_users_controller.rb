class LdapUsersController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :require_admin
  accept_key_auth :create

  def new
    @auth_sources = AuthSourceLdap.all
  end

  def create

    users = params[:users][:users].split(/\W+/) #.reject(&:empty?)
    auth_source = AuthSourceLdap.find(params[:users][:auth_source])

    created = []
    rejected = []
    not_found = []

    unless users.empty? || auth_source.nil?

      users.each do |login|
        next unless find_by_login(login).nil?

        attrs = auth_source.get_user(login)
        if attrs
          user = User.new(attrs)
          user.login = login
          user.language = Setting.default_language
          if user.save
            created << user.name
          else
            rejected << login
          end
        else
          rejected << login
        end
      end

      unless created.empty?
        message = "Users were created:<br />"
        message += created.map { |name| h(name) }.join("<br />")
        flash[:notice] = message
      end

      @users = rejected.join(' ')
      @auth_sources = AuthSourceLdap.all
      render :action => 'new'
    end

  end

end