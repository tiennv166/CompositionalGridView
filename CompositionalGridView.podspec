Pod::Spec.new do |s|
  s.name = 'CompositionalGridView'
  s.version = '1.0.0'
  s.summary = 'A compositional collection view that can display items in a grid and list arrangement.'
  s.homepage = 'https://github.com/tiennv166/CompositionalGridView'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'tiennv166' => 'tiennv166@gmail.com' }
  s.source = { :git => 'https://github.com/tiennv166/CompositionalGridView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'CompositionalGridView/Classes/**/*'
end
