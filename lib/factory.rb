class Factory
  class << self
    def new(*args, &block)
      const_set(args.shift.capitalize, class_new(*args, &block)) if args.first.is_a?(String)
      class_new(*args, &block)
    end

    def class_new(*args, &block)
      Class.new do
        attr_accessor(*args)

        def initialize(*vars)
          raise ArgumentError, "Expected #{args.count} argument(s)" if args.count != vars.count

          args.each_index do |index|
            instance_variable_set("@#{args[index]}", vars[index])
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
          to_h.each_pair(&pair)
        end

        def dig(*args)
          first_arg = self[args.first]
          return nil if first_arg == nil
          args.one? ? first_arg : first_arg.dig(*args[1..-1])
        end

        def to_h
          args.zip(values).to_h
        end

        def length
          args.size
        end

        def select(&block)
          values.select(&block)
        end

        def values
          instance_variables.map { |arg| instance_variable_get(arg) }
        end

        def values_at(*indexes)
          indexes.map { |index| values[index] }
        end

        def ==(other)
          self.class == other.class && self.values == other.values
        end

        class_eval(&block) if block_given?

        alias_method :to_a, :values
        alias_method :eql?, :==
        alias_method :size, :length
        alias_method :members, :args
      end
    end
  end
end
