Pod::Spec.new do |spec|
  spec.name = 'Observatory'
  spec.version = '0.2.4'
  spec.summary = 'Cocoa and Carbon event, notification and hotkey observing framework 🔭 in pure Swift 💯'
  spec.license = { :type => 'MIT' }
  spec.homepage = 'https://github.com/swifteroid/stone'
  spec.authors = { 'Ian Bytchek' => 'ianbytchek@gmail.com' }

  spec.platform = :osx, '10.11'

  spec.source = { :git => 'https://github.com/swifteroid/stone.git', :tag => "#{spec.version}" }
  spec.source_files = 'source/**/*.{swift,h,m}'
  spec.exclude_files = 'source/Test', 'source/Testing'
  spec.swift_version = '4'

  spec.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Release]' => '-suppress-warnings' }
end