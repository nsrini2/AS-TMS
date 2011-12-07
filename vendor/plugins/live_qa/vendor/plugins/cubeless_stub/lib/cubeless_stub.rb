# CubelessStub
module CubelessStub
    
end

require 'cubeless_stub/models'
Object.__send__ :include, CubelessStub::Models

require 'cubeless_stub/controllers'
ActionController::Base.__send__ :include, CubelessStub::Controllers

require 'cubeless_stub/helpers'
ActionView::Base.__send__ :include, CubelessStub::Helpers
