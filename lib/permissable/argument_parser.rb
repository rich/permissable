module Jamlab
  module Permissable
    class ArgumentParser
      def initialize(method_name, target, args)
        @method_name = method_name.to_s
        @target = target
        @args = args
      end

      def is_admin?
        @admin_check ||= @method_name.match(/^admin_.*\!/) ? true : false
      end

      def is_reversed?
        @reversed_check ||= @method_name.match(/can_(not_)?be_.*/) ? true : false
      end

      def is_negated?
        @negated_check ||= @method_name.match(/^can_not/) ? true : false
      end

      def is_assigning?
        @assigned_check ||= @method_name.match(/\!$/) ? true : false
      end

      def has_accessible?
        @accessible_check ||= accessible.any? ? false : true
      end

      def has_controllable?
        @controllable_check ||= controllable.any? ? false : true
      end
      
      def has_action?
        @action_check ||= !action.blank?
      end

      def is_valid?
        case
        # Stephen and Ruby's regex operators can DIAF
        when !@method_name.match(/^can.*\?|\!$/)
          false
        when !is_assigning? && (has_accessible? || has_controllable?)
          true
        else
          has_action?
        end
      end

      def action
        @action ||= Permission.normalize_permission_action((@method_name.match(/can_(not_)?(be_)?([a-z_]+?)_?(by)?(\?|\!)/i)[3] rescue "").downcase)
      end
      
      def accessible
        @accessible_pair ||= extract_object_pair(*(is_reversed? ? @target : @args))
      end
      
      def controllable
        @controllable_pair ||= extract_object_pair(*(is_reversed? ? @args : @target))
      end
      
      def args
        @args_array ||= (controllable + accessible).flatten
      end
      
      private
        def extract_object_pair(*args)
          case
          when args.size == 2 && [Symbol, String].member?(args.first.class)
            [args.first.to_s, args.last]
          when args.size == 1 && args.first.is_a?(ActiveRecord::Base)
            [args.first.class.to_s, args.first.id]
          else
            [nil, nil]
          end
        end
    end
  end
end
