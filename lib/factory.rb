# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  def self.new(*args, &block)
    const_set(args.shift.capitalize, class_new(*args, &block)) if args.first.is_a?(String)
    class_new(*args, &block)
  end

  def self.class_new(*args, &block)
    Class.new do
      attr_accessor(*args)

      class_eval(&block) if block_given?

      def initialize(*vars)
        raise ArgumentError, 'Extra arguments passed.' if args.count != vars.count

        args.each_index do |index|
          instance_variable_set(:"@#{args[index]}", vars[index])
        end
      end

      define_method :args do
        args
      end

      def [](arg)
        arg.is_a?(Integer) ? values[arg] : instance_variable_get("@#{arg}")
      end

      def []=(arg, value)
        instance_variable_set("@#{arg}", value)
      end

      def each(&block)
        values.each(&block)
      end

      def each_pair(&pair)
        hash.each_pair(&pair)
      end

      def dig(*args)
        hash.dig(*args)
      end

      def hash
        Hash[instance_variables.map do |variable|
          [variable.to_s.delete('@').to_sym, instance_variable_get(variable)]
        end]
      end

      def length
        args.size
      end

      def members
        return_array = []
        args.each do |arg|
          return_array << arg
        end
        return_array
      end

      def select(&block)
        values.select(&block)
      end

      def values
        instance_variables.map { |arg| instance_variable_get(arg) }
      end

      def values_at(*indexes)
        return_array = Array.new
        indexes.each { |index| return_array << values[index] }
        return_array
      end

      def ==(obj)
        self.class == obj.class && self.values == obj.values
      end

      alias_method :to_a, :values
      alias_method :eql?, :==
      alias_method :size, :length
    end
  end
end
