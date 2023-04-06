Pod::Spec.new do |s|
  s.name             = "ExyteChat"
  s.version          = "0.0.1"
  s.summary          = "Chat with fully customizable message cells and built-in media picker written with SwiftUI"

  s.homepage         = 'https://github.com/exyte/Chat.git'
  s.license          = 'MIT'
  s.author           = { 'Exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/Chat.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = '16.0'
  
  s.requires_arc = true
  s.swift_version = "5.7"

  s.source_files = [
     'Sources/*.h',
     'Sources/*.swift',
     'Sources/**/*.swift'
  ]

end
