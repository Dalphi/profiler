registration = DalphiProfiler::Registration.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')
authentification = DalphiProfiler::Authentification.new(email: 'darrel.marvin@example.com', password: 'Pb9bWr42Lw01Vm')

project = DalphiProfiler::Project.new(title: 'bluetooth port indexing')
annotator = DalphiProfiler::Annotator.new name: 'Kailey Ledner DVM', email: 'foo@example.com'

# registration.register_admin
authentification.login_admin

# annotator.create
# annotator.destroy

# project.create
# project.destroy

# annotator.assign_to_project('bluetooth port indexing')
# annotator.unassign_from_project('bluetooth port indexing')

# authentification.logout_admin
# registration.unregister_admin
