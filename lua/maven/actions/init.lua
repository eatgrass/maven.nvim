local M = {}

M.create_project = require("maven.actions.create_project").create_project
M.add_dependency_to_pom = require("maven.actions.add_dependency_to_pom").add_dependency_to_pom
return M
