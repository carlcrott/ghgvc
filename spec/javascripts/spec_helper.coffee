#= require application
#= require sinon
#= require sinon-chai

mocha.ignoreLeaks()

beforeEach ->
  @sandbox = sinon.sandbox.create()

afterEach ->
  @sandbox.restore()
