source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'Checklist'
platform :ios, '15.0'

inhibit_all_warnings!
use_frameworks!

target 'Checklist' do
  project 'Checklist/Checklist.xcodeproj'
  pod 'MobileWorkflow', '~> 2.1.13'
  pod 'ChecklistPlugin', path: 'ChecklistPlugin.podspec'

  target 'ChecklistTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
    require 'fileutils'
    FileUtils.mkdir_p('Pods/Pods.xcodeproj/xcshareddata/xcschemes')
    FileUtils.cp('ChecklistPlugin.xcscheme', 'Pods/Pods.xcodeproj/xcshareddata/xcschemes/ChecklistPlugin.xcscheme')
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

module AggregateTargetSettingsExtensions
  def ld_runpath_search_paths
    return super unless configuration_name == "Debug"
    return (super || []) + (framework_search_paths || [])
  end
end

class Pod::Target::BuildSettings::AggregateTargetSettings
  prepend AggregateTargetSettingsExtensions
end

module PodTargetSettingsExtensions
  def ld_runpath_search_paths
    return (super || []) + (framework_search_paths || [])
  end
end

class Pod::Target::BuildSettings::PodTargetSettings
  prepend PodTargetSettingsExtensions
end

