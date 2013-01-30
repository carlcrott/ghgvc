module Biome
  # This error is raised when BioEntry descentant class doesn't
  # override #value_condition method
  class AbstractInvocationError < StandardError; end

  # Base class for all bio-entries
  # Contains common logic for all inherited classes.
  #
  class BioEntry

    attr_accessor :name, :lng_range, :lat_range, :out_coordinates, :cdf_filename, :cdf_var, :coordinates

    # Initializer
    #
    # @param [ Hash ] options - hash of initialization parameters
    #
    # @option options [ String ] name - entry name
    # @option options [ CoordinateRange ] lng_range - longitude range
    # @option options [ CoordinateRange ] lat_range - latitude range
    # @option options [ Coordinates ] out_coordinates - coordinate of
    #   point to scale coordinates to
    # @option options [ String ] cdf_filename - name of the NetCDF file
    # @option options [ String ] cdf_var - name of the var to read
    #   from cdf file
    # @option options [ Coordinates ] coordinates - coordinates of the
    #   point to check
    #
    def initialize(options = {})
      @name = options[:name]
      @lng_range = options[:lng_range]
      @lat_range = options[:lat_range]
      @out_coordinates = options[:out_coordinates]
      @cdf_filename = options[:cdf_filename]
      @cdf_var = options[:cdf_var]
      @coordinates = options[:coordinates]
    end

    # Checks whether or no the entry should be treated as 'included'
    # for the given coordinates
    #
    # @return [ true, false ] true if value is included
    def included?
      within_range? and value_condition
    end

    # Check if coordinates are within given ranges
    #
    # @return [ true, false ] true if the coordinates are within range
    def within_range?
      lng_range.include?(coordinates.lng) && lat_range.include?(coordinates.lat)
    end

    # Gets the entry value. If not initialized - reads it from file
    #
    # @return [ Float ] value
    def value
      @value ||= read_value
    end

    # Reads the value from file
    #
    # @return [ Float ] value read
    def read_value
      scaled_coordinates = coordinates.scale(lng_range, lat_range, out_coordinates )
      cdf = NumRu::NetCDF.open(cdf_filename)
      result = cdf.var(cdf_var)[scaled_coordinates.lng, scaled_coordinates.lat, 0, 0][0]
      cdf.close()
      result
    end

    # Should not be called on BioEntry but on it's child classes'
    # objects. Return true if the entry should be treated as 'included'
    #
    # @raise [ AbstractInvocationError ] if this method is not overriden
    #   in object's class
    def value_condition
      raise AbstractInvocationError.new "Entry class should override :value_condition method"
    end
  end

  ## US SpringWheat
  # This map has an ij coordinate range of (0,0) to (80, 50)
  # top left LatLng being (49.75 ,-105.25)
  # bottom right LatLng being (24.75 ,-65.25)
  # Therefore it sits between:
  # Lat 24.75 and 49.75
  # Lon -105.25 and -65.25
  # http://localhost:3000/get_biome.json?lng=-97.25&lat=44.75 # =>
  # 0.0956562
  class UsSpringWheat < BioEntry
    def initialize(coordinates)
      super({
              name: "spring wheat",
              lng_range: CoordinateRange.new(-105.25, -65.25),
              lat_range: CoordinateRange.new(24.75, 49.75),
              out_coordinates: Coordinates.new(80, 50),
              cdf_filename: "netcdf/GCS/Crops/US/SpringWheat/fractioncover/fswh_2.7_us.0.5deg.nc",
              cdf_var: "fswh",
              coordinates: coordinates
            })
    end

    # value condition when the entry matches coordinates
    def value_condition
      value.present?
    end
  end

  ## US Soybean
  # This map has an ij coordinate range of (0,0) to (80, 50)
  # top left LatLng being (49.75 ,-105.25)
  # bottom right LatLng being (24.75 ,-65.25)
  # Therefore it sits between:
  # Lat 24.75 and 49.75
  # Lon -105.25 and -65.25
  class UsSoybean < BioEntry
    def initialize(coordinates)
      super({
              name: "soybean",
              lng_range: CoordinateRange.new(-105.25, -65.25),
              lat_range: CoordinateRange.new(24.75, 49.75),
              out_coordinates: Coordinates.new(80, 50),
              cdf_filename: "netcdf/GCS/Crops/US/Soybean/fractioncover/fsoy_2.7_us.0.5deg.nc",
              cdf_var: "fsoy",
              coordinates: coordinates
            })
    end

    # value condition when the entry matches coordinates
    def value_condition
      value.present? && value < 0.01
    end
  end

  ## US Corn
  # This map has an ij coordinate range of (0,0) to (80, 50)
  # top left LatLng being (49.75 ,-105.25)
  # bottom right LatLng being (25.25 ,-65.25)
  # Therefore it sits between:
  # Lat 24.75 and 49.75
  # Lon -105.25 and -65.25
  # http://localhost:3000/get_biome?lng=-83.25&lat=44.25 # => 0.18501955270767212
  class UsCorn < BioEntry
    def initialize(coordinates)
      super({
              name: "corn",
              lng_range: CoordinateRange.new(-105.25, -65.25),
              lat_range: CoordinateRange.new(24.75, 49.75),
              out_coordinates: Coordinates.new(80, 50),
              cdf_filename: "netcdf/GCS/Crops/US/Corn/fractioncover/fcorn_2.7_us.0.5deg.nc",
              cdf_var: "fcorn",
              coordinates: coordinates
            })
    end

    # value condition when the entry matches coordinates
    def value_condition
      value.present? && value > 0.01
    end
  end

  ## Brazil Sugarcane
  # This map has an ij coordinate range of (0,0) to (59, 44)
  # top left LatLng being (-60.25 ,-4.75)
  # bottom right LatLng being (-30.75 ,-26.75)
  # Therefore it sits between:
  # Lat -4.75 and -26.75
  # Lon -30.75 and -60.25
  class BrasilSugarcane < BioEntry
    def initialize(coordinates)
      super({
              name: "brazil sugarcane",
              lng_range: CoordinateRange.new(-60.25, -30.75),
              lat_range: CoordinateRange.new(-26.75, -4.75),
              out_coordinates: Coordinates.new(59, 44),
              cdf_filename: "netcdf/GCS/Crops/Brazil/Sugarcane/brazil_sugc_latent_10yr_avg.nc",
              cdf_var: "latent",
              coordinates: coordinates
            })
    end

    # value condition when the entry matches coordinates
    def value_condition
      value.present? && value < 110
    end
  end

  ## Vegtype
  # This map has an ij coordinate range of (0,0) to (720, 360)
  # top left LatLng being (89.75, -179.25)
  # top left LatLng being (-89.75, 179.25)
  # Therefore it sits between:
  # Lat -89.75 and 89.75
  # Lon -179.25 and 179.25
  class Vegtype < BioEntry
    def initialize(coordinates)
      super({
              name: "spring wheat",
              lng_range: CoordinateRange.new(-179.25, 179.25),
              lat_range: CoordinateRange.new(-89.75, 89.75),
              out_coordinates: Coordinates.new(720, 360),
              cdf_filename: "netcdf/vegtype.nc",
              cdf_var: "vegtype",
              coordinates: coordinates
            })
    end

    # value condition when the entry matches coordinates
    def value_condition
      value <= 15
    end
  end
end
