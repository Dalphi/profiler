#!/usr/bin/env ruby

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'faker'

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = 'http://localhost:3000'

module DalphiProfiler
  class Authentification
    include Capybara::DSL

    def initialize(email: nil, password: nil)
      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @email = email
      @password = password
    end

    def login_admin
      visit '/auth/admins/sign_in'

      fill_in 'admin_email', with: @email
      fill_in 'admin_password', with: @password

      click_button 'Sign in'
    end

    def logout_admin
      visit '/'

      find(:css, '.sign-out').trigger('click')
    end
  end

  class Registration
    include Capybara::DSL

    def initialize(email: nil, password: nil)
      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @email = email
      @password = password
    end

    def register_admin
      visit('/auth/admins/sign_up')

      fill_in 'admin_email', with: @email
      fill_in 'admin_password', with: @password
      fill_in 'admin_password_confirmation', with: @password

      click_button 'Sign up'

      { email: @email, password: @password }
    end

    def unregister_admin
      visit '/auth/admins/edit'

      click_on 'Cancel My Account'
    end
  end
end

session = Capybara::Session.new(:poltergeist)
credentials = {:email=>"darrel.marvin@example.com", :password=>"Pb9bWr42Lw01Vm"}
registration = DalphiProfiler::Registration.new credentials
authentification = DalphiProfiler::Authentification.new credentials

registration.register_admin

# authentification.login_admin
# authentification.logout_admin

registration.unregister_admin

