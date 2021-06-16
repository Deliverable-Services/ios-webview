 # Uncomment the next line to define a global platform for your project
inhibit_all_warnings!
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
platform :ios, '11.0'


workspace 'Porcelain.xcworkspace'
install! 'cocoapods', :deterministic_uuids => false

target 'Porcelain' do
  #new implementation
  pod 'Siren'
  pod 'AlignedCollectionViewFlowLayout'
  pod 'SwiftyJSON'
  pod 'PhoneNumberKit'
  pod 'Socket.IO-Client-Swift', '13.3.0'
  pod 'Stripe', '~> 19.4.0'
  pod 'CountryPickerView'
  pod 'Cosmos', '17.0.0'
  pod 'CenteredCollectionView'
  pod 'Kingfisher'
  pod 'NVActivityIndicatorView', '~> 4.8.0'
  pod 'FreshchatSDK'
  pod 'Firebase', '~> 6.17.0'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'GoogleSignIn'
  pod 'YPImagePicker'
  pod 'DTPhotoViewerController'
  pod 'MXParallaxHeader', '~> 1.0.0'
  pod 'MXSegmentedPager'
  pod 'CardScan'
  pod 'CardScan/Stripe'
  pod 'SwipeCellKit'
  pod 'SwiftMessages', '= 5.0.1'
  pod 'UPCarouselFlowLayout'
  pod 'UICircularProgressRing', '~> 3.0.0'
  pod 'MarqueeLabel'
  pod 'Toast-Swift'
  
  # Workaround for Cocoapods issue #7606
  # https://github.com/CocoaPods/CocoaPods/issues/7606
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end
  
  target 'NotificationServiceExtension' do
    inherit! :search_paths
  end
  
  target 'PorcelainTests' do # Pods for testing
    inherit! :search_paths
  end
end

target 'R4pidKit' do
  project '../R4pidKit/R4pidKit.xcodeproj'  #path from li from root
  
  pod 'SwiftyJSON'
  pod 'Kingfisher'
end
