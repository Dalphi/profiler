registration = DalphiProfiler::Registration.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')
authentification = DalphiProfiler::Authentification.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')

project_title = 'bluetooth port indexing'
project = DalphiProfiler::Project.new(title: project_title)
annotator = DalphiProfiler::Annotator.new(name: 'Kailey Ledner DVM', email: 'foo@example.com')
raw_datum = DalphiProfiler::RawDatum.new(project_title: project_title)

# registration.register_admin
authentification.login_admin

# annotator.create
# annotator.destroy

# project.create
# project.destroy

raw_datum.create
# raw_datum.destroy_all

# annotator.assign_to_project('bluetooth port indexing')
# annotator.unassign_from_project('bluetooth port indexing')

# authentification.logout_admin
# registration.unregister_admin
