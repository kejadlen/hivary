glob = File.join(File.dirname(__FILE__), '*.rb')
Dir[glob].each {|f| require f }
