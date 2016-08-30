require 'dry/logic/operators'
require 'dry/logic/applicable'

module Dry
  module Logic
    class Rule
      include Dry::Equalizer(:predicate, :options)
      include Operators
      include Applicable

      DEFAULT_OPTIONS = { args: [].freeze, result: nil }.freeze

      attr_reader :predicate

      attr_reader :options

      attr_reader :name

      attr_reader :args

      attr_reader :arity

      def initialize(predicate, options = DEFAULT_OPTIONS)
        super
        @predicate = predicate
        @options = options
        @name = options[:name]
        @args = options[:args]
        @arity = options[:arity] || predicate.arity
      end

      def type
        :rule
      end

      def call(*input)
        with(args: [*args, *input], result: self[*input])
      end

      def [](*input)
        arity == 0 ? predicate.() : predicate[*args, *input]
      end

      def curry(*new_args)
        all_args = args + new_args

        if all_args.size > arity
          raise ArgumentError, "wrong number of arguments (#{all_args.size} for #{arity})"
        else
          with(args: all_args)
        end
      end

      def with(new_opts)
        self.class.new(predicate, options.merge(new_opts))
      end

      private

      def parameters
        predicate.parameters
      end

      def args_with_names
        parameters.map(&:last).zip(args + Array.new(arity - args.size, Undefined))
      end
    end
  end
end
