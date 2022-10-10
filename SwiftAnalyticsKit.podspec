Pod::Spec.new do |s|
  s.name              = 'SwiftAnalyticsKit'

  require_relative 'Helpers/spec'
  s.extend SwiftAnalyticsKit::Spec
  s.common_spec

  s.documentation_url = "https://swiftylab.github.io/SwiftAnalyticsKit/#{s.version}/documentation/analytics/"
  s.default_subspec   = 'Core'

  s.subspec 'Core' do |cs|
    cs.dependency 'SwiftAnalyticsKitCore', "= #{s.version}"
  end

  s.subspec 'Mock' do |ms|
    ms.dependency 'SwiftAnalyticsKitMock', "= #{s.version}"
  end

  s.test_spec do |ts|
    ts.source_files = "Tests/AnalyticsTests/**/*.swift"
    ts.dependency 'SwiftAnalyticsKit/Core'
    ts.dependency 'SwiftAnalyticsKit/Mock'
  end
end
