Gem::Specification.new do |s|
  s.name = 'remotedroid'
  s.version = '0.6.3'
  s.summary = 'A Ruby-MacroDroid related experiment into triggering macros ' + 
      'and responding to actions remotely.'
  s.authors = ['James Robertson']
  s.files = Dir[
    'lib/remotedroid.rb', 
    'lib/remotedroid/model.rb', 
    'lib/remotedroid/query.rb', 
    'lib/remotedroid/control.rb', 
    'lib/remotedroid/controller.rb',     
    'lib/remotedroid/client.rb'    
  ]  
  s.add_runtime_dependency('onedrb', '~> 0.1', '>=0.1.0')
  s.add_runtime_dependency('easydom', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('sps-sub', '~> 0.3', '>=0.3.7')
  s.add_runtime_dependency('sps-pub', '~> 0.5', '>=0.5.5')
  s.add_runtime_dependency('apphttp', '~> 0.2', '>=0.2.0')
  s.add_runtime_dependency('ruby-macrodroid', '~> 0.9', '>=0.9.17')
  s.signing_key = '../privatekeys/remotedroid.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/remotedroid'
end
