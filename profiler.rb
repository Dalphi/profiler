#!/usr/bin/env ruby

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'faker'

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.default_max_wait_time = 10
Capybara.app_host = ARGV[0]

module DalphiProfiler
  class Authentification
    include Capybara::DSL

    def initialize(email: nil, password: nil)
      page.driver.browser.js_errors = false

      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @email = email
      @password = password
    rescue
      puts "error in Authentification#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def login_admin
      visit '/auth/admins/sign_in'

      fill_in 'admin_email', with: @email
      fill_in 'admin_password', with: @password

      click_button 'Sign in'
    rescue
      puts "error in Authentification#login_admin"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def logout_admin
      visit '/'

      find(:css, '.sign-out').trigger('click')
    rescue
      puts "error in Authentification#logout_admin"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class Registration
    include Capybara::DSL

    def initialize(email: nil, password: nil)
      page.driver.browser.js_errors = false

      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @email = email
      @password = password
    rescue
      puts "error in Registration#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def register_admin
      visit('/auth/admins/sign_up')

      fill_in 'admin_email', with: @email
      fill_in 'admin_password', with: @password
      fill_in 'admin_password_confirmation', with: @password

      click_button 'Sign up'

      { email: @email, password: @password }
    rescue
      puts "error in Registration#register_admin"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def unregister_admin
      visit '/auth/admins/edit'

      click_on 'Cancel My Account'
    rescue
      puts "error in Registration#unregister_admin"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class Project
    include Capybara::DSL

    def initialize(title: nil, description: nil, iterate_service: nil, merge_service: nil, interfaces: nil)
      page.driver.browser.js_errors = false

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
    rescue
      puts "error in Project#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
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
    rescue
      puts "error in Project#create"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def destroy
      visit '/projects'

      click_on @title
      click_on 'Edit project'
      find(:css, '.btn-danger').trigger('click')
    rescue
      puts "error in Project#destroy"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class Annotator
    include Capybara::DSL

    def initialize(name: nil, email: nil, password: nil)
      page.driver.browser.js_errors = false

      name ||= Faker::Name.name
      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @name = name
      @email = email
      @password = password
    rescue
      puts "error in Annotator#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def create
      visit '/annotators'

      fill_in 'annotator[name]', with: @name
      fill_in 'annotator[email]', with: @email
      fill_in 'annotator[password]', with: @password

      click_on 'New annotator'
    rescue
      puts "error in Annotator#create"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def destroy
      visit '/annotators'

      click_on @name
      click_on 'Delete'
    rescue
      puts "error in Annotator#destroy"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def assign_to_project(project_title: nil)
      visit '/projects'

      click_on project_title
      within :css, '.nav-tabs' do
        click_on 'Annotators'
      end

      select "#{@name} (#{@email})", from: 'project_annotator'
      click_on 'Add annotator'
    rescue
      puts "error in Annotator#assign_to_project"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def unassign_from_project(project_title: nil)
      visit '/projects'
      puts project_title

      within :css, '.nav-tabs' do
        click_on 'Annotators'
      end

      click_on @name
      click_on 'Unassign annotator from project'
    rescue
      puts "error in Annotator#unassign_to_project"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class RawDatum
    include Capybara::DSL

    def initialize(project_title: nil, files: nil)
      page.driver.browser.js_errors = false

      unless files
        file = Tempfile.new(['', '.json'])
        file.write(
          {
            character: Faker::StarWars.character,
            droid: Faker::StarWars.droid,
            planet: Faker::StarWars.planet,
            quote: Faker::StarWars.quote,
            specie: Faker::StarWars.specie,
            vehicle: Faker::StarWars.vehicle,
            wookie_sentence: Faker::StarWars.wookie_sentence
          }.to_json
        )
        file.rewind
        files = [file]
      end

      @project_title = project_title
      @files = files
    rescue
      puts "error in RawDatum#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def create
      visit '/projects'

      click_on @project_title
      click_on 'Raw Data'
      click_on 'New raw datum'

      page.evaluate_script '$("#raw_datum_data").removeAttr("accept")'

      attach_file 'raw_datum_data', @files.map(&:path)

      find(:css, '.btn-primary').trigger('click')
    rescue
      puts "error in RawDatum#create"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def destroy_all
      visit '/projects'

      click_on @project_title
      click_on 'Raw Data'
      click_on 'Delete all'
    rescue
      puts "error in RawDatum#destroy_all"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class AnnotationDocument
    include Capybara::DSL

    def initialize(project_title: nil)
      page.driver.browser.js_errors = false

      @project_title = project_title
    rescue
      puts "error in AnnotationDocument#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def create
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Generate annotation documents'
    rescue
      puts "error in AnnotationDocument#create"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def destroy_all
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Delete all'
    rescue
      puts "error in AnnotationDocument#destroy_all"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end

  class Annotation
    include Capybara::DSL

    def initialize(project_title: nil)
      page.driver.browser.js_errors = false

      @project_title = project_title
    rescue
      puts "error in Annotation#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def annotate(label_words: nil)
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      visit "#{page.find("[href*='annotate']")[:href]}&synchronous_request=true"

      label_words.each do |label, words|
        page.find(".#{label}").trigger('click')
        words.each do |word|
          page.all('span', text: word).each do |token|
            token.trigger('click')
          end
        end
      end if label_words

      click_on 'Save annotation'
    rescue
      puts "error in Annotation#annotate"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def merge
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Merge'
    rescue
      puts "error in Annotation#merge"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end
  end
end

session = Capybara::Session.new(:poltergeist)

eval(
  File.open(
    File.expand_path(ARGV[1])
  ).read
)
