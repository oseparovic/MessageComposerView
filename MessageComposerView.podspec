Pod::Spec.new do |s|
  name               = "MessageComposerView"
  url                = "https://github.com/oseparovic/#{name}"
  git_url            = "#{url}.git"
  version            = "1.1.2"

  s.name             = name
  s.version          = version
  s.summary          = "A library to provide an iMessage like input box that sticks to the keyboard."
  s.homepage         = url
  s.screenshots      = "http://www.thegameengine.org/wp-content/uploads/2013/11/message_composer_quad_1.jpg"
  s.license          = 'MIT'
  s.author           = { "Oskar Separovic" => "oseparovic@gmail.com" }
  s.source           = { :git => git_url, :tag => version }
  s.social_media_url = 'https://twitter.com/alexgophermix'
  s.requires_arc     = true
  s.source_files     = "#{name}/*.{h,m}"
  s.resources        = "#{name}/*.{xib}"
  s.platform         = :ios, '6.0'
end
