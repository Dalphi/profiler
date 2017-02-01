# Dalphi profiler

A component to profile and test a Dalphi setup.

## Usage

```bash
./profiler.rb https://dalphi.example.com /path/to/my/profile.rb
```

## Creating a profile

It is possible to create a profile by writing the desired use cases to be profiled to a Ruby file.

### Registration

The `registration` object allows to `register_admin` and `unregister_admin`.

```ruby
registration = DalphiProfiler::Registration.new email: 'darrel.marvin@example.com',
                                                password: 'Pb9bWr42Lw01Vm'

registration.register_admin # registers an administrator with the specified credentials
registration.unregister_admin # unregisters an administrator with specified email
```

### Authentification

The `authentification` object is capable of `login_admin` and `logout_admin`.

```ruby
authentification = DalphiProfiler::Authentification.new email: 'darrel.marvin@example.com',
                                                        password: 'Pb9bWr42Lw01Vm'

authentification.login_admin # logs in an administrator with the specified credentials
authentification.logout_admin # logs out any logged in administrator
```

### Project

The `project` object can `create` and `destroy` a project.

```ruby
project = DalphiProfiler::Project.new title: 'bluetooth port indexing',
                                      description: "I'll override the cross-platform IB panel, that should bus the JSON interface!",
                                      iterate_service: 'MaxEnt NER Iterator (synchronous)',
                                      merge_service: 'RawDatum replacer (synchronous)',
                                      interfaces: { 'ner_complete' => 'NER complete' }

project.create # creates a project with the specified preferences
project.destroy # destroys a project with the specified title
```

### Annotator

The `annotator` object can `create` and `destroy` an annotator.
Project access can be granted with `assign_to_project` and `unassign_from_project`.

```ruby
annotator = DalphiProfiler::Annotator.new name: 'Kailey Ledner',
                                          email: 'kailey@example.com',
                                          password: 'Gn2gLp5v0nZ8Zj'

annotator.create # creates an annotator with the specified name and credentials
annotator.destroy # destroys an annotator identified by the name

annotator.assign_to_project('bluetooth port indexing') # assignes the annotator identified by the name and email to the project identified by its title
annotator.unassign_from_project('bluetooth port indexing') # unassignes the annotator identified by its name from the project identified by its title
```
