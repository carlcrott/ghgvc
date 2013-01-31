require 'spec_helper'

describe Biome::Biome do

  it 'should provide :for_coordinates class proxy for initializer' do
    coordinates = mock
    @it = Biome::Biome
    @it.expects(:new).with(coordinates)
    @it.for_coordinates(coordinates)
  end

  describe 'biome interface' do
    before :each do
      coordinates = mock('coordinates')
      @it = Biome::Biome.new coordinates
    end

    it 'should initialize ecosystems from file' do
      @it.ecosystems.should_not be_empty
    end

    it 'should evaluate native only once' do
      @it.expects(:get_native).once.returns('')
      2.times { @it.native }
    end

    it 'should evaluate biofuels only once' do
      @it.expects(:collect_names).once.returns([])
      2.times { @it.biofuels }
    end

    it 'should evaluate agroecosystems only once' do
      @it.expects(:collect_names).once.returns([])
      2.times { @it.agroecosystems }
    end

    it 'should correctly serialize biome to JSON' do
      @it.stubs(native: 'native', agroecosystems: ['agro'],
                biofuels: ['bio1', 'bio2'])
      @it.to_json.should == {
        "native" => "native",
        "biofuels" => {"name" => "bio1,bio2"},
        "agroecosystems" => {"name" => "agro"}
      }.to_json
    end
  end

  describe 'collect_names' do
    before :each do
      coordinates = mock('coordinates')
      @it = Biome::Biome.new coordinates
      corn = mock('corn', 'included?' => true, 'name' => 'corn')
      Biome::UsCorn.stubs(:new).returns(corn)
      sugar = mock('sugar', 'included?' => false)
      Biome::BrasilSugarcane.stubs(:new).returns(sugar)
      @entries = [Biome::UsCorn, Biome::BrasilSugarcane]
    end

    it 'should collect included entries\' names' do
      @it.send(:collect_names, @entries).should include('corn')
    end

    it 'should not contain not included entries' do
      @it.send(:collect_names, @entries).should_not include('sugar')
    end

    it 'should not contain nil elements' do
      @it.send(:collect_names, @entries).should_not include(nil)
    end
  end

  describe 'native' do

    before :each do
      coordinates = mock('coordinates')
      @it = Biome::Biome.new coordinates
    end

    it 'should be nil if not included' do
      vegtype = mock('vegtype', 'included?' => false)
      Biome::Vegtype.stubs(:new).returns(vegtype)
      @it.native.should be_nil
    end

    it 'should return native based on ecosystem if included' do
      vegtype = mock('vegtype', 'included?' => true, 'value' => 1)
      Biome::Vegtype.stubs(:new).returns(vegtype)
      @it.native.should == @it.ecosystems[1]
    end
  end
end

describe Biome::Coordinates do
  before :each do
    @it = Biome::Coordinates.new(10, 20)
  end

  it 'should correctly initialize coordinates' do
    @it.lng.should == 10
    @it.lat.should == 20
  end

  it 'should be able to scale coordinates by scaling each coordinate' do
    @it.expects(:scale_coordinate).times(2)
    @it.scale(mock, mock('lat_range', inverse: {}), Biome::Coordinates.new(100, 200))
  end
end

describe Biome::CoordinateRange do
  before :each do
    @it = Biome::CoordinateRange.new(0, 100)
  end

  it 'should correctly initialize coordinates' do
    @it.min.should == 0
    @it.max.should == 100
  end

  it 'correctly checks whether the value is within range' do
    @it.include?(50).should be_true
  end

  it 'correctly checks whether the value is outside range' do
    @it.include?(-50).should be_false
  end

  it 'treats range borders as included' do
    @it.include?(0).should be_true
    @it.include?(100).should be_true
  end

  it 'should correctly inverse range' do
    inverse = @it.inverse
    @it.min.should == inverse.max
    @it.max.should == inverse.min
  end
end
