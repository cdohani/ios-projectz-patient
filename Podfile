# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DocHyve Patient' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DocHyve Patient
 pod 'MBProgressHUD'
 pod 'IQKeyboardManagerSwift'
 pod 'TagListView', '~> 1.0'
 pod 'Localize-Swift', '~> 3.2'
 pod 'PinCodeTextField'
 pod 'Cosmos'
 pod 'FSCalendar'
 pod 'GoogleMaps'
 pod 'GooglePlaces'
 pod 'FirebaseCore'
 pod 'FirebaseCrashlytics'
 pod 'FirebaseMessaging'
 pod 'GoogleSignIn'
 #pod 'JitsiMeetSDK'

 post_install do |installer|
     installer.generated_projects.each do |project|
         project.targets.each do |target|
             target.build_configurations.each do |config|
                 config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
             end
         end
     end
 end
 
end
