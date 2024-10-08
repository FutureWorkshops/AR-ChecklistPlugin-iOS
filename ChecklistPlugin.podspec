Pod::Spec.new do |s|
  s.name                  = 'ChecklistPlugin'
    s.version               = '1.0.2'
  s.summary               = 'A plugin for AppRail.'
  s.homepage              = 'https://app-rail.io'
  s.license               = { :type => 'Copyright', :file => 'LICENSE' }
  s.author                = { 'Future Workshops' => 'info@futureworkshops.com' }
  s.source                = { :git => 'https://github.com', :tag => "#{s.version}" }
  s.platform              = :ios
  s.swift_version         = '5'
    s.ios.deployment_target = '17.1'
  s.default_subspecs      = 'Core'

  s.subspec 'Core' do |cs|
        cs.dependency            'MobileWorkflow', '~> 2.1.29'
    cs.source_files       = 'ChecklistPlugin/ChecklistPlugin/**/*.swift'
  end
end
