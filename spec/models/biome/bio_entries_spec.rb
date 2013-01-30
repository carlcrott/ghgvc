require 'spec_helper'

describe Biome::BioEntry do
  describe 'included' do
    before :each do
      @it = Biome::BioEntry.new
    end

    it 'should check within_range and value_condition' do
      @it.expects(:within_range?).returns(true)
      @it.expects(:value_condition).returns(true)
      @it.included?.should be_true
    end

    it 'should correctly determine coordinates within range' do
      @it.stubs(lng_range: Biome::CoordinateRange.new(-105.25, -65.25),
                lat_range: Biome::CoordinateRange.new(24.75, 49.75),
                coordinates: Biome::Coordinates.new(-97.25, 44.75))
      @it.within_range?.should be_true
    end

    it 'should treat coordinates outside if latitude outside range' do
      @it.stubs(lng_range: Biome::CoordinateRange.new(-105.25, -65.25),
                lat_range: Biome::CoordinateRange.new(24.75, 49.75),
                coordinates: Biome::Coordinates.new(-97.25, 54.75))
      @it.within_range?.should be_false
    end

    it 'should treat coordinates outside if longitude outside range' do
      @it.stubs(lng_range: Biome::CoordinateRange.new(-105.25, -65.25),
                lat_range: Biome::CoordinateRange.new(24.75, 49.75),
                coordinates: Biome::Coordinates.new(-27.25, 44.75))
      @it.within_range?.should be_false
    end

    it 'BioEntry descendants should be forced to override value_condition' do
      custom_entry = Class.new Biome::BioEntry
      instance = custom_entry.new
      expect { instance.send(:value_condition) }.to raise_error Biome::AbstractInvocationError
    end
  end

  describe 'value' do
    before :each do
      @it = Biome::BioEntry.new
    end

    it 'should read value only once' do
      @it.expects(:read_value).once.returns('')
      2.times { @it.value }
    end

    it 'should read value from net_cdf file' do
      @it.stubs(lng_range: Biome::CoordinateRange.new(-105.25, -65.25),
                lat_range: Biome::CoordinateRange.new(24.75, 49.75),
                coordinates: Biome::Coordinates.new(-97.25, 44.75),
                out_coordinates: Biome::Coordinates.new(80, 50),
                cdf_filename: 'test',
                cdf_var: 'var')

      cdf = mock('cdf', close: nil)
      NumRu::NetCDF.expects(:open).with('test').returns(cdf)
      cdf.expects(:var).with('var').returns(mock('var', :[] => []))
      @it.send :read_value
    end
  end
end

describe Biome::UsSpringWheat  do
  before :each do
    @it = Biome::UsSpringWheat.new(Biome::Coordinates.new(-97.25, 44.75))
  end

  it 'should be within range' do
    @it.within_range?.should be_true
  end

  it 'should correctly calculate value' do
    @it.value.should be_within(1.0e-07).of(0.0956562)
  end

  it 'should be included' do
    @it.included?.should be_true
  end
end

describe Biome::UsSoybean  do
  before :each do
    @it = Biome::UsSoybean.new(Biome::Coordinates.new(-97.25, 44.75))
  end

  it 'should be within range' do
    @it.within_range?.should be_true
  end

  it 'should correctly calculate value' do
    @it.value.should be_within(1.0e-07).of(0.1485121)
  end

  it 'should not be included' do
    @it.included?.should be_false
  end
end

describe Biome::UsCorn  do
  before :each do
    @it = Biome::UsCorn.new(Biome::Coordinates.new(-83.25, 44.25))
  end

  it 'should be within range' do
    @it.within_range?.should be_true
  end

  it 'should correctly calculate value' do
    @it.value.should be_within(1.0e-07).of(0.18501955)
  end

  it 'should be included' do
    @it.included?.should be_true
  end
end

describe Biome::BrasilSugarcane  do
  before :each do
    @it = Biome::BrasilSugarcane.new(Biome::Coordinates.new(-40.25, -10.25))
  end

  it 'should be within range' do
    @it.within_range?.should be_true
  end

  it 'should correctly calculate value' do
    @it.value.should be_within(1.0e-07).of(61.041011810302734)
  end

  it 'should be included' do
    @it.included?.should be_true
  end
end

describe Biome::Vegtype  do
  before :each do
    @it = Biome::Vegtype.new(Biome::Coordinates.new(-40.25, -10.25))
  end

  it 'should be within range' do
    @it.within_range?.should be_true
  end

  it 'should correctly calculate value' do
    @it.value.should be_within(1.0e-07).of(1)
  end

  it 'should be included' do
    @it.included?.should be_true
  end
end
