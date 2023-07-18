pipeline {
  agent {
    label 'macos-latest'
  }
   
  stages {
    stage('Setup') {
            steps {
                sh 'xcode-select --install' // Install Xcode command-line tools
                sh 'brew install git ruby' // Install Git and Ruby using Homebrew
                sh 'sudo gem install cocoapods' // Install CocoaPods
                // Install additional dependencies as required
                
                // Set up iOS simulators
                sh 'xcodebuild -showsdks' // List available simulators
                // Install simulators using xcodebuild -sdk <sdk_identifier> install
                
                // Set up any other necessary configurations
            }
        }
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    
    stage('Check Xcode version') {
      steps {
        sh '/usr/bin/xcodebuild -version'
      }
    }
    
    stage('Install the Apple certificate and provisioning profile') {
      environment {
        P12_PASSWORD = credentials('p12_password')
      }
      steps {
        sh '''
          cp Certificates.p12 $RUNNER_TEMP/build_certificate.p12
          cp DemoTest.mobileprovision $RUNNER_TEMP/build_pp.mobileprovision

          security import $RUNNER_TEMP/build_certificate.p12 -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k ~/Library/Keychains/login.keychain-db
          security list-keychain -d user -s ~/Library/Keychains/login.keychain-db

          mkdir -p ~/Library/MobileDevice/Provisioning Profiles
          cp $RUNNER_TEMP/build_pp.mobileprovision ~/Library/MobileDevice/Provisioning Profiles
        '''
      }
    }
    
    stage('Copy Podfile') {
      steps {
        sh 'cp -r SignIn/Podfile .'
      }
    }
    
    stage('Install CocoaPods') {
      steps {
        sh '''
          sudo gem install cocoapods -v '1.11.2'
          pod repo list
          pod setup
        '''
      }
    }
    
    // Add more stages for the remaining steps in your workflow
    // ...
    
    stage('Build and Export') {
      steps {
        sh '''
          xcodebuild archive -workspace SignIn/SignIn.xcworkspace \
            -scheme SignIn -archivePath "$RUNNER_TEMP/SignIn.xcarchive" \
            -sdk iphonesimulator -configuration Debug \
            -destination 'platform=iOS Simulator,name=iPhone 13 Pro Max,OS=16.2' \
            clean archive DEVELOPMENT_TEAM="X372X3URRM" \
            PROVISIONING_PROFILE_SPECIFIER="DemoTest" -allowProvisioningUpdates \
            | tee build_output.txt

          xcodebuild -exportArchive \
            -archivePath "$RUNNER_TEMP/SignIn.xcarchive/Products/Applications/SignIn.app" \
            -exportPath "$RUNNER_TEMP/IPA" \
            -exportOptionsPlist ExportOptions.plist \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
        '''
      }
    }
  }
}
