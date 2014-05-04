#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  name               = "MessageComposerView"
  url                = "https://github.com/oseparovic/#{name}"
  git_url            = "#{url}.git"
  version            = "1.0.0"
  source_files       = "#{name}/*.{h,m,xib}"

  s.name             = name
  s.version          = version
  s.summary          = "A library to provide an iMessage like input box that sticks to the keyboard."
  s.homepage         = url
  s.screenshots      = "http://www.thegameengine.org/wp-content/uploads/2013/11/message_composer_quad_1.jpg"
  s.license          = 'MIT'
  s.author           = { "Oskar Separovic" => "oseparovic@gmail.com" }
  s.source           = { :git => git_url, :tag => version }
  s.social_media_url = 'https://twitter.com/alexgophermix'

  # s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc     = true

  s.source_files     = source_files
  # s.resources = 'Assets/*.png'

  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
