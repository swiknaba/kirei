# typed: strict
# frozen_string_literal: true

# this must run **after** Kirei has booted and been initialized
# auto generates klasses dynamically. See lib/kirei/templates/**/*.rb

#
# Generates "Relations::XXRelation" klasses for app/models
#
Dir[
  File.join(Kirei.root, "app/models/**/*.rb"),
].each do |model_file|
  require(model_file)

  full_klass_name = T.must(model_file[%r{.*/app/(.*)\.rb}, 1]).classify
  klass = full_klass_name.constantize # rubocop:disable Sorbet/ConstantsFromStrings
  klass_name = T.let(File.basename(model_file, ".rb").camelize, String)
  table_name = klass.table_name

  eval(Templates::RelationKlass.erb(klass_name, klass, table_name)) # rubocop:disable Security/Eval
end
