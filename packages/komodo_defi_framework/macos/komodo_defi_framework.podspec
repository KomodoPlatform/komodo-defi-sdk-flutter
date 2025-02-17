Pod::Spec.new do |s|
  s.name             = 'komodo_defi_framework'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.public_header_files = 'Classes/**/*.h'

  # Ensure source files are included
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.resource_bundles = {
    'kdf_resources' => 'bin/kdf'
  }

  s.script_phase = {
    :name => 'Install kdf executable',
    :execution_position => :before_compile,
    :script => <<-SCRIPT
      # Get the application support directory for macOS
      APP_SUPPORT_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Library/Application Support"
      
      # Ensure the application support directory exists
      if [ ! -d "$APP_SUPPORT_DIR" ]; then
        mkdir -p "$APP_SUPPORT_DIR"
      fi
  
      # Check if the kdf executable exists before attempting to copy
      if [ -f "${PODS_TARGET_SRCROOT}/bin/kdf" ]; then
        echo "kdf executable found, copying..."
        cp "${PODS_TARGET_SRCROOT}/bin/kdf" "$APP_SUPPORT_DIR/kdf"
        chmod +x "$APP_SUPPORT_DIR/kdf"
      else
        echo "Error: kdf executable not found in bin/kdf"
        exit 1
      fi
    SCRIPT
  }
  

  # Correct configuration for macOS build
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=macosx*]' => 'i386 x86_64',
    'OTHER_LDFLAGS' => '-framework SystemConfiguration'
  }

  s.platform = :osx, '10.14'
  s.swift_version = '5.0'
end
