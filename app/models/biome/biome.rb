require_relative 'bio_entries'

module Biome
  # This class is used to aggregate and simplify access to particular
  # coordinate BioEntries
  #
  # @example
  #   Biome::Biome.for_coordinates(Coordinates.new(27, -15))
  #
  class Biome
    attr_accessor :biofuels, :agrosystems, :native, :ecosystems, :coordinates

    # List of biofuel classes
    BIOFUELS = [UsSoybean, UsCorn, BrasilSugarcane]

    # List of agroecosystems classes
    AGROECOSYSTEMS = [UsSpringWheat]

    class << self
      # Gets the Biome object for specified coordinates
      #
      # @param [ Coordinates ] coordinates
      #
      # @return [ Biome ] biome object
      def for_coordinates(coordinates)
        self.new(coordinates)
      end
    end

    def initialize(coordinates)
      @coordinates = coordinates
      # open data/default_ecosystems.json and parse
      # object returned is an array of hashes...
      #
      # @example
      #   p @ecosystems[0] # will return a Hash
      #   p @ecosystems[0]["category"] # => "native"
      @ecosystems = JSON.parse( File.open( "#{Rails.root}/data/default_ecosystems.json" , "r" ).read )
    end

    def native
      @native ||= get_native
    end

    def biofuels
      @biofuels ||= collect_names(BIOFUELS)
    end

    def agroecosystems
      @agroecosystems ||= collect_names(AGROECOSYSTEMS)
    end

    # Overrides to_json method to match needed format
    # TODO: Consider using RABL templates for this instead
    def to_json
      {
        native: native,
        biofuels: {
          name: biofuels.join(",")
        },
        agroecosystems: {
          name: agroecosystems.join(",")
        }
      }.to_json
    end

    private

    # Collect names from the list of bioentries classes which contain
    # Biome coordinates and have TRUE value_condition
    #
    # @example
    #   [UsCorn] --> ["corn"] assuming it has approproiate value and is within range
    #
    # @param [ Array ] entries - list of classes inherited from `BioEntry`
    #
    # @return [ Array ] array of string names
    def collect_names(entries)
      names = entries.collect do |entry_class|
        entry = entry_class.new(coordinates)
        entry.name if entry.included?
      end
      names.compact
    end

    # Gets the native value
    #
    # @return [ String ] native value
    def get_native
      vegtype = Vegtype.new(coordinates)
      ecosystems[vegtype.value] if vegtype.included?
    end
  end

  # Couple of longitude and latitude
  class Coordinates < Struct.new(:lng, :lat)
    # Scales coordinate according to the range
    #
    # @param [ CoordinateRange ] lng_range - longitude range
    # @param [ CoordinateRange ] lat_range - latitude range
    # @param [ Coordinates ] out_coordinates - coordinate of the
    #   corner point to scale to
    def scale(lng_range, lat_range, out_coordinates)
      Coordinates.new(scale_coordinate(lng, lng_range, out_coordinates.lng),
                      scale_coordinate(lat, lat_range.inverse, out_coordinates.lat))
    end

    private

    # Scales one coordinate measure according to output value
    #
    def scale_coordinate(input, range, output)
      # map onto [0,1] using input range
      frac = (input - range.min ) / ( range.max - range.min )
      # map onto output value
      (frac * output).round()
    end
  end

  # Intenger range for Coordinae measure
  class CoordinateRange < Struct.new(:min, :max)

    # Checks whether or noot the coordinate lies within range
    #
    # @return [ true, false ] true if the range include coordinate
    def include?(coordinate)
      (min..max).cover? coordinate
    end

    # Replaces max and min (used for scaling)
    #
    # @return [ CoordinateRange ] inversed range
    def inverse
      CoordinateRange.new(max, min)
    end
  end
end
