Pod::Spec.new do |s|
    s.name             = 'mm2_plugin'
    s.version          = '0.0.1'
    s.summary          = 'MM2 plugin for Flutter.'
    s.description      = <<-DESC
  A new Flutter plugin for MM2.
                         DESC
    s.homepage         = 'http://example.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'email@example.com' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.public_header_files = 'Classes/**/*.h'
    s.dependency 'Flutter'
    s.platform = :ios, '11.0'
    s.vendored_libraries = 'libmm2.a'
  
    # Flutter.framework does not contain a i386 slice.
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  end