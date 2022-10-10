Pod::Spec.new do |s|
  s.name        = 'SwiftAnalyticsKitMock'
  s.module_name = 'AnalyticsMock'

  require_relative 'Helpers/spec'
  s.extend SwiftAnalyticsKit::Spec
  s.common_spec
  s.file_spec

  s.frameworks = 'XCTest'
  s.dependency 'SwiftAnalyticsKitCore', "= #{s.version}"
end
