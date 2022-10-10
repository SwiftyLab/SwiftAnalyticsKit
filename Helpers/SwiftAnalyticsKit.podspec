require 'json'

Pod::Spec.new do |s|
  s.name              = 'SwiftAnalyticsKit'

  require_relative 'spec'
  s.extend SwiftAnalyticsKit::Spec
  s.common_spec

  s.documentation_url = "https://swiftylab.github.io/SwiftAnalyticsKit/#{s.version}/documentation/analytics/"
  s.default_subspec   = 'Core'
  
  s.subspec 'Core' do |cs|
    cs.vendored_frameworks = "Analytics.xcframework"
  end

  s.subspec 'Mock' do |ms|
    ms.vendored_frameworks = "AnalyticsMock.xcframework"
  end
end
