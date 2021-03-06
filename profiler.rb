#!/usr/bin/env ruby

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'faker'
require 'httparty'

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.default_max_wait_time = 20
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
      save_screenshot("#{Dir.pwd}/public/system/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def login_annotator
      visit '/auth/annotators/sign_in'

      fill_in 'annotator_email', with: @email
      fill_in 'annotator_password', with: @password

      click_button 'Sign in'
    rescue
      puts "error in Authentification#login_annotator"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def logout_admin
      logout
    rescue
      puts "error in Authentification#logout_admin"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def logout_annotator
      logout
    rescue
      puts "error in Authentification#logout_annotator"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def logout
      visit '/'

      find(:css, '.sign-out').trigger('click')
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

  class Service
    include Capybara::DSL

    def initialize(url: nil, title: nil)
      @url = url
      @title = title
    rescue
      puts "error in Service#initialize"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def register
      /(?<protocol>http|https):\/\/(?<uri>.*)/ =~ @url
      visit "/services/new?protocol=#{protocol}&uri=#{URI.escape(uri)}"
      fill_in 'service[title]', with: @title if @title
      find(:css, '.btn-primary').trigger('click')
    end

    def unregister
      visit '/services'
      click_on @url
      find(:css, '.btn-danger').trigger('click')
    end
  end

  class Interface
    include Capybara::DSL

    def initialize(title: nil, interface_type_name: nil, associated_problem_identifiers: nil, html: nil, coffee: nil, scss: nil, dalphi_storage: nil, profiler_storage: nil)
      @dalphi_storage ||= '/usr/src/app/public/system'
      @profiler_storage ||= '/usr/src/app/public/system'
      @title = title
      @interface_type_name = interface_type_name
      @associated_problem_identifiers = associated_problem_identifiers
      @html = html
      @coffee = coffee
      @scss = scss
    end

    def create
      visit '/interfaces/new'

      fill_in 'interface[title]', with: @title
      fill_in 'interface[interface_type][name]', with: @interface_type_name
      page.execute_script("$('#interface_associated_problem_identifiers').attr('value', 'ner')")

      find(:css, '.btn-primary').trigger('click')

      path = find(:css, '.pro-tip .input-group:nth-of-type(1) input').value.gsub(@dalphi_storage, @profiler_storage)
      File.write path, @html

      path = find(:css, '.pro-tip .input-group:nth-of-type(2) input').value.gsub(@dalphi_storage, @profiler_storage)
      File.write path, @coffee

      path = find(:css, '.pro-tip .input-group:nth-of-type(3) input').value.gsub(@dalphi_storage, @profiler_storage)
      File.write path, @scss

      click_on 'Refresh'
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

      while !page.has_content?(@title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(@name) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

      click_on @name
      click_on 'Delete'
    rescue
      puts "error in Annotator#destroy"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def assign_to_project(project_title: nil)
      visit '/projects'

      while !page.has_content?(project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

      click_on project_title

      within :css, '.nav-tabs' do
        click_on 'Annotators'
      end

      while !page.has_content?(@name) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
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

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

      click_on @project_title
      click_on 'Raw Data'
      click_on 'New raw datum'

      page.evaluate_script '$("#raw_datum_data").removeAttr("accept")'

      attach_file 'raw_datum_data', @files

      find(:css, '.btn-primary').trigger('click')
    rescue
      puts "error in RawDatum#create"
      save_screenshot("#{Dir.pwd}/error-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")
      raise
    end

    def destroy_all
      visit '/projects'

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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

      while !page.has_content?(@project_title) && page.has_css?('a.next_page')
        find(:css, 'a.next_page').trigger('click')
      end

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
