require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

module Spec
  module Matchers
    class Be
      def predicate_with_is_support
        if @actual.respond_to?("is_#{@expected.to_s}?")
          "is_#{@expected.to_s}?".to_sym
        else
          predicate_without_is_support
        end
      end
      alias_method_chain :predicate, :is_support
    end
  end
end