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

annotator.assign_to_project project_title: 'bluetooth port indexing' # assignes the annotator identified by the name and email to the project identified by its title
annotator.unassign_from_project project_title: 'bluetooth port indexing' # unassignes the annotator identified by its name from the project identified by its title
```

### RawDatum

The `raw_datum` object can `create` a datum and `destroy_all` of them.

```ruby
raw_datum = DalphiProfiler::RawDatum.new project_title: 'bluetooth port indexing',
                                         files: ['/path/to/your/raw_datum_1.json', '/path/to/your/raw_datum_2.json']

raw_datum.create # creates a raw datum with the given file for the project with the specified project title
raw_datum.destroy_all # destroys all raw data associated to the project with the given title
```

### AnnotationDocument

The `annotation_document` object can `create` a datum and `destroy_all` of them.

```ruby
annotation_document = DalphiProfiler::AnnotationDocument.new project_title: 'bluetooth port indexing'

annotation_document.create # creates an annotation document for the project with the specified project title
annotation_document.destroy_all # destroys all annotation documents associated to the project with the given title
```

### Annotation

The `annotation` object can `annotate` an annotation document or `merge` all annotated annotation documents.

```ruby
annotation = DalphiProfiler::Annotation.new project_title: 'bluetooth port indexing'

annotation.annotate label_words: { 'PER': ['Linus Torvalds', 'Richard Stallman'], 'COM': ['Linux Foundation', 'Canonical'] } # annotates one annotation document with the given words for the coresponding labels
annotation.merge # merges all annotated annotation documents back to the corresponding raw datum
```
