registration = DalphiProfiler::Registration.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')
authentification = DalphiProfiler::Authentification.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')

project_title = 'bluetooth port indexing'
project = DalphiProfiler::Project.new(title: project_title)
annotator = DalphiProfiler::Annotator.new(name: 'Kailey Ledner DVM', email: 'foo@example.com')

# registration.register_admin
authentification.login_admin

# annotator.create
# annotator.destroy

# project.create
# project.destroy

# files = []
# 10.times do |i|
#   files << File.open("/tmp/new-washington-post-#{(i + 1)}.json")
# end
# raw_datum = DalphiProfiler::RawDatum.new(project_title: project_title, files: files)
#
# raw_datum.create
# raw_datum.destroy_all

annotation_document = DalphiProfiler::AnnotationDocument.new(project_title: project_title)
# annotation_document.create
# annotation_document.destroy_all

annotation = DalphiProfiler::Annotation.new(project_title: project_title)
annotation.annotate

# annotator.assign_to_project('bluetooth port indexing')
# annotator.unassign_from_project('bluetooth port indexing')

# authentification.logout_admin
# registration.unregister_admin
