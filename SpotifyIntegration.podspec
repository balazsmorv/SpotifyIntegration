Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "SpotifyIntegration"
s.summary = "SpotifyIntegration adds the Spotify SDK to your app, along with helper classes."
s.requires_arc = true

# 2
s.version = "0.1.5"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Morvay Balazs" => "balazsmorvay@yahoo.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/balazsmorv/SpotifyIntegration"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/balazsmorv/SpotifyIntegration.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'RxSwift', '~> 6.0'
s.dependency 'RxCocoa', '~> 6.0'

# 8
s.source_files = "SpotifyIntegration/*.{swift,xib}"

# 9
#s.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"


s.preserve_path = "SpotifyiOS/module.modulemap"
s.module_map = "SpotifyiOS/module.modulemap"

#s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => "$(PROJECT_DIR)/SpotifyiOS.framework/Versions/A/Headers/" }
#s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(PROJECT_DIR)/SpotifyiOS.framework/Versions/A/Headers/" }

# 10
s.swift_version = "5.2"

end
