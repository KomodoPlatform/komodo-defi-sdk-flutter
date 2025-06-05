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
    'kdf_resources' => ['bin/kdf', 'lib/*.dylib'].select { |f| Dir.exist?(File.dirname(f)) }
  }

  s.script_phase = {
    :name => 'Install kdf executable and/or dylib',
    :execution_position => :before_compile,
    :script => <<-SCRIPT
      # Get the application support directory for macOS
      APP_SUPPORT_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Library/Application Support"
      FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Contents/Frameworks"
      
      # Ensure the application support directory exists
      if [ ! -d "$APP_SUPPORT_DIR" ]; then
        mkdir -p "$APP_SUPPORT_DIR"
      fi
      
      # Ensure the frameworks directory exists
      if [ ! -d "$FRAMEWORKS_DIR" ]; then
        mkdir -p "$FRAMEWORKS_DIR"
      fi
      
      # Track if we found at least one of the required files
      FOUND_REQUIRED_FILE=0
  
      # Check if the kdf executable exists and copy it
      if [ -f "${PODS_TARGET_SRCROOT}/bin/kdf" ]; then
        echo "kdf executable found, copying..."
        cp "${PODS_TARGET_SRCROOT}/bin/kdf" "$APP_SUPPORT_DIR/kdf"
        chmod +x "$APP_SUPPORT_DIR/kdf"
        FOUND_REQUIRED_FILE=1
      else
        echo "Warning: kdf executable not found in bin/kdf"
      fi
      
      # Check if the dylib exists and copy it
      if [ -f "${PODS_TARGET_SRCROOT}/lib/libkdflib.dylib" ]; then
        echo "libkdflib.dylib found, copying..."
        cp "${PODS_TARGET_SRCROOT}/lib/libkdflib.dylib" "$FRAMEWORKS_DIR/libkdflib.dylib"
        install_name_tool -id "@rpath/libkdflib.dylib" "$FRAMEWORKS_DIR/libkdflib.dylib"
        FOUND_REQUIRED_FILE=1
      else
        echo "Warning: libkdflib.dylib not found in lib/libkdflib.dylib"
      fi
      
      # Fail if neither file was found
      if [ $FOUND_REQUIRED_FILE -eq 0 ]; then
        echo "Error: Neither kdf executable nor libkdflib.dylib was found. At least one is required."
        exit 1
      fi
    SCRIPT
  }
  
  # Configuration for macOS build
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=macosx*]' => 'i386 x86_64',
    'OTHER_LDFLAGS' => '-framework SystemConfiguration',
    # Add rpath to ensure dylib can be found at runtime
    'LD_RUNPATH_SEARCH_PATHS' => [
      '$(inherited)',
      '@executable_path/../Frameworks',
      '@loader_path/Frameworks'
    ]
  }

  # Ensure dylibs are properly linked
  s.libraries = ['c++', 'resolv']

  s.platform = :osx, '10.14'
  s.swift_version = '5.0'
end
