require 'thor'

module GitSnip
  module Options
    def self.merge(primary = {}, secondary = {})
      primary = primary.dup

      primary.each_pair do |k, v|
        if v.is_a?(Array) && v.empty?
          secondary_value = secondary[k]

          if secondary_value.is_a?(Array) && secondary_value.any?
            primary[k] = secondary_value
          end
        end
      end

      Thor::CoreExt::HashWithIndifferentAccess.new(
        secondary.merge(primary)).freeze
    end
  end
end
