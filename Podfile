xcodeproj 'Respoke/Respoke.xcodeproj'

pod 'RespokeSocket.IO', :git => 'https://github.com/respoke/socket.IO-objc.git', :tag => '0.5.3'
pod 'RespokeSocketRocket', :git => 'https://github.com/respoke/SocketRocket', :tag => '0.3.2'
pod 'Respoke', :path => './RespokeSDK'

target :RespokeTests, :exclusive => true do
  pod 'KIF', '~> 3.0', :configurations => ['Debug']
end
