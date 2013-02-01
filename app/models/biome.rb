require "numru/netcdf"

module Biome
  class Range < Struct.new(:min, :max)
    def include?(val)
      max >= val && val >= min
    end
  end

  class Point < Struct.new(:x, :y)
  end

  class Biofuel
    attr_accessor :name, :cdf_path, :cdf_var, :lng, :lat, :ij_range

    def initialize(options = {})
      @name = options[:name]
      @cdf_path = options[:cdf_path]
      @cdf_var = options[:cdf_var]
      @lng = options[:lng]
      @lat = options[:lat]
      @ij_range = options[:ij_range]
    end

    def covers?(lng, lat)
      @lat.include?(lat) && @lng.include?(lng)
    end

    def num(lng, lat)
      i = remap_range(lng, @lng.min, @lng.max, 0, @ij_range.x)
      j = remap_range(lat, @lat.max, @lat.min, 0, @ij_range.y)
      cdf = NumRu::NetCDF.open(cdf_path)
      result = cdf.var(@cdf_var)[i, j, 0, 0][0]
      cdf.close()
      result
    end

    private
      def remap_range(input, in_low, in_high, out_low, out_high)
        frac = (input - in_low) / (in_high - in_low) # map onto [0,1] using input range
        (frac * (out_high - out_low) + out_low).to_i.round() # map onto output range
      end
  end

  class Biome
    def initialize(lng, lat)
      @lng = lng
      @lat = lat
    end

    def to_json
      return {} if @lng.nil? || @lat.nil?

      default = {
        lng: Range.new(-105.25, -65.25),
        lat: Range.new(24.75, 49.75),
        ij_range: Point.new(80, 50)
      }

      ## US SpringWheat
      # This map has an ij coordinate range of (0,0) to (80, 50)
      # top left LatLng being (49.75 ,-105.25)
      # bottom right LatLng being (24.75 ,-65.25)
      # Therefore it sits between:
      # Lat 24.75 and 49.75
      # Lon -105.25 and -65.25
      @USSpringWheat = Biofuel.new({
        name: "spring wheat",
        cdf_path: "netcdf/GCS/Crops/US/SpringWheat/fractioncover/fswh_2.7_us.0.5deg.nc",
        cdf_var: "fswh"
      }.merge(default))
      
      ## US Soybean
      # This map has an ij coordinate range of (0,0) to (80, 50)
      # top left LatLng being (49.75 ,-105.25)
      # bottom right LatLng being (24.75 ,-65.25)
      # Therefore it sits between:
      # Lat 24.75 and 49.75
      # Lon -105.25 and -65.25
      @USSoybean = Biofuel.new({
        name: "soybean",
        cdf_path: "netcdf/GCS/Crops/US/Soybean/fractioncover/fsoy_2.7_us.0.5deg.nc",
        cdf_var: "fsoy"
      }.merge(default))
      
      ## US Corn
      # This map has an ij coordinate range of (0,0) to (80, 50)
      # top left LatLng being (49.75 ,-105.25)
      # bottom right LatLng being (25.25 ,-65.25)
      # Therefore it sits between:
      # Lat 24.75 and 49.75
      # Lon -105.25 and -65.25
      @USCorn = Biofuel.new({
        name: "corn",
        cdf_path: "netcdf/GCS/Crops/US/Corn/fractioncover/fcorn_2.7_us.0.5deg.nc",
        cdf_var: "fcorn"
      }.merge(default))

      ## Brazil Sugarcane
      # This map has an ij coordinate range of (0,0) to (59, 44)
      # top left LatLng being (-60.25 ,-4.75)
      # bottom right LatLng being (-30.75 ,-26.75)
      # Therefore it sits between:
      # Lat -4.75 and -26.75
      # Lon -30.75 and -60.25
      @BrazilSugarcane = Biofuel.new({
        name: "brazil sugarcane",
        cdf_path: "netcdf/GCS/Crops/Brazil/Sugarcane/brazil_sugc_latent_10yr_avg.nc",
        cdf_var: "latent",
        lng: Range.new(-60.25, -30.75),
        lat: Range.new(-26.75, -4.75),
        ij_range: Point.new(59, 44)
      })

      ## Vegtype
      # This map has an ij coordinate range of (0,0) to (720, 360)
      # top left LatLng being (89.75, -179.25)
      # top left LatLng being (-89.75, 179.25)
      # Therefore it sits between:
      # Lat -89.75 and 89.75
      # Lon -179.25 and 179.25
      @Vegtype = Biofuel.new({
        name: "native",
        cdf_path: "netcdf/vegtype.nc",
        cdf_var: "vegtype",
        lng: Range.new(-179.25, 179.25),
        lat: Range.new(-89.75, 89.75),
        ij_range: Point.new(720, 360)
      })
   
      # open data/default_ecosystems.json and parse
      # object returned is an array of hashes... Ex:
      # p @ecosystems[0] # will return a Hash
      # p @ecosystems[0]["category"] # => "native"
      @ecosystems = JSON.parse(File.open("#{Rails.root}/data/default_ecosystems.json", "r").read)

      @json = {}
      vegtype_num = @Vegtype.num(@lng, @lat)
      @json["native"] = @ecosystems[vegtype_num] if vegtype_num <= 15

      @biofuel_names = []
      @agroecosystem_names = []
      
      if @USSpringWheat.covers?(@lng, @lat)
        @agroecosystem_names << @USSpringWheat.name
      end

      if @USSoybean.covers?(@lng, @lat) && @USSoybean.num(@lng, @lat) < 0.01
        @biofuel_names << @USSoybean.name
      end

      if @USCorn.covers?(@lng, @lat) && @USCorn.num(@lng, @lat) > 0.01
        @biofuel_names << @USCorn.name
      end

      if @BrazilSugarcane.covers?(@lng, @lat) && @BrazilSugarcane.num(@lng, @lat) < 110
        @biofuel_names << @BrazilSugarcane.name
      end
      
      @json["biofuels"]       = { name: @biofuel_names.join(",") }
      @json["agroecosystems"] = { name: @agroecosystem_names.join(",") }
      @json
    end
  end
end