#!/usr/bin/env ruby

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'faker'

Capybara.run_server = false
Capybara.default_max_wait_time = 10
Capybara.app_host = ARGV[0]
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

module DalphiProfiler
  def wait_for_ajax
    include Capybara::DSL

  end

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

      click_on @title
      click_on 'Edit project'
      find(:css, '.btn-danger').trigger('click')
    end
  end

  class Annotator
    include Capybara::DSL

    def initialize(name: nil, email: nil, password: nil)
      name ||= Faker::Name.name
      email ||= Faker::Internet.safe_email
      password ||= Faker::Internet.password

      @name = name
      @email = email
      @password = password
    end

    def create
      visit '/annotators'

      fill_in 'annotator[name]', with: @name
      fill_in 'annotator[email]', with: @email
      fill_in 'annotator[password]', with: @password

      click_on 'New annotator'
    end

    def destroy
      visit '/annotators'

      click_on @name
      click_on 'Delete'
    end

    def assign_to_project(project_title: nil)
      visit '/projects'

      click_on project_title
      within :css, '.nav-tabs' do
        click_on 'Annotators'
      end

      select "#{@name} (#{@email})", from: 'project_annotator'
      click_on 'Add annotator'
    end

    def unassign_from_project(project_title: nil)
      visit '/projects'
      puts project_title

      within :css, '.nav-tabs' do
        click_on 'Annotators'
      end

      click_on @name
      click_on 'Unassign annotator from project'
    end
  end

  class RawDatum
    include Capybara::DSL

    def initialize(project_title: nil, files: nil)
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
    end

    def create
      visit '/projects'

      click_on @project_title
      click_on 'Raw Data'
      click_on 'New raw datum'

      page.evaluate_script '$("#raw_datum_data").removeAttr("accept")'

      attach_file 'raw_datum_data', @files.map(&:path)

      find(:css, '.btn-primary').trigger('click')
    end

    def destroy_all
      visit '/projects'

      click_on @project_title
      click_on 'Raw Data'
      click_on 'Delete all'
    end
  end

  class AnnotationDocument
    include Capybara::DSL

    def initialize(project_title: nil)
      @project_title = project_title
    end

    def create
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Generate annotation documents'
    end

    def destroy_all
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Delete all'
    end
  end

  class Annotation
    include Capybara::DSL

    def initialize(project_title: nil)
      @project_title = project_title
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

      # save_screenshot("/tmp/annotation-document-#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}.png")

      click_on 'Save annotation'
    end

    def merge
      visit '/projects'

      click_on @project_title
      click_on 'Annotation Documents'
      click_on 'Merge'
    end
  end
end

session = Capybara::Session.new(:poltergeist)

eval(
  File.open(
    File.expand_path(ARGV[1])
  ).read
)
