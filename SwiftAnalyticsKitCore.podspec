Pod::Spec.new do |s|
  s.name        = 'SwiftAnalyticsKitCore'
  s.module_name = 'Analytics'

  require_relative 'Helpers/spec'
  s.extend SwiftAnalyticsKit::Spec
  s.common_spec
  s.file_spec
end
