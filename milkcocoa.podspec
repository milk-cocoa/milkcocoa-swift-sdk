Pod::Spec.new do |s|
  s.name         = "milkcocoa"
  s.version      = "1.0"
  s.summary      = "Milkcocoa swift SDK."
  s.homepage     = "https://mlkcca.com/"
  s.license      = "MIT"
  s.author       = "contact@mlkcca.com"

  s.platform     = :ios, "9.1"

  s.source       = { :git => "https://github.com/mokemoko/milkcocoa-swift-sdk.git", :tag => "#{s.version}" }
  s.source_files = "MilkCocoa/*.{h,m,swift}"

  s.dependency "CocoaMQTT", "~> 1.0.7"
end
