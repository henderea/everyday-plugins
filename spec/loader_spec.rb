require_relative '../lib/everyday-plugins/plugin'
class Loader1
  extend EverydayPlugins::Loader
end

describe EverydayPlugins::Loader do
  it 'runs the block when the dependencies are met' do
    rval = false
    Loader1.depend(['bundler', '~> 1.5'], 'rake') { rval = true }
    rval.should be_true
  end

  it 'does not run the block when the dependencies are not met' do
    rval = false
    Loader1.depend(['bundler', '>= 10.5'], 'rake') { rval = true }
    rval.should be_false
  end

  it 'runs the block when the dependencies are met using a static method' do
    rval = false
    EverydayPlugins::Loader.depend(['bundler', '~> 1.5'], 'rake') { rval = true }
    rval.should be_true
  end

  it 'does not run the block when the dependencies are not met using a static method' do
    rval = false
    EverydayPlugins::Loader.depend(['bundler', '>= 10.5'], 'rake') { rval = true }
    rval.should be_false
  end
end