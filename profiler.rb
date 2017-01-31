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

  class Project
    include Capybara::DSL

    def initialize(title: nil, description: nil, iterate_service: nil, merge_service: nil, interfaces: nil)
      title ||= "#{Faker::Hacker.adjective} #{Faker::Hacker.noun} #{Faker::Hacker.ingverb}"
      description ||= Faker::Hacker.say_something_smart
      iterate_service ||= 'MaxEnt NER Iterator (synchronous)'
      merge_service ||= 'RawDatum replacer (synchronous)'
      interfaces ||= { 'ner_complete' => 'NER complete' }

      @title = title
      @description = description
      @iterate_service = iterate_service
      @merge_service = merge_service
      @interfaces = interfaces
    end

    def create
      visit '/projects/new'

      fill_in 'title', with: @title
      fill_in 'description', with: @description
      select @iterate_service, from: 'project_iterate_service'
      select @merge_service, from: 'project_merge_service'

      find(:css, '.btn-primary').trigger('click')
      click_on 'Dashboard'
      click_on 'Edit project'

      @interfaces.each do |interface_type, interface|
        within(:css, ".project_interfaces.#{interface_type}") do
          select interface, from: 'project_interfaces'
        end
      end

      find(:css, '.btn-primary').trigger('click')
    end

    def destroy
      visit '/projects'

      click_on "#{@title}"
      click_on 'Edit project'
      find(:css, '.btn-danger').trigger('click')
    end
  end
end

session = Capybara::Session.new(:poltergeist)

registration = DalphiProfiler::Registration.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')
authentification = DalphiProfiler::Authentification.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')

project = DalphiProfiler::Project.new(title: 'bluetooth port indexing')

registration.register_admin
# authentification.login_admin

project.create
# project.destroy

# authentification.logout_admin
registration.unregister_admin
