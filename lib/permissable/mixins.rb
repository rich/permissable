module Jamlab
  module Permissable
    module Mixin
      def self.included(base)
        base.alias_method_chain(:method_missing, :permissions)
        base.send(:extend, ClassMethods)
      end

      def method_missing_with_permissions(name, *args)
        # This is part of the ArgumentParser#is_valid? check but
        # I want to bail out very quickly if we're obviously not
        # even remotely valid.
        return method_missing_without_permissions(name, *args) unless name.to_s.match(/^can.*\?|\!$/)
        
        @method = Jamlab::Permissable::ArgumentParser.new(name, self, args)
        if @method.is_valid?
          case
          when !@method.is_assigning?
            p = Permission.check(@method.action, @method.args)
            @method.is_negated? ? !p : p
          when @method.is_assigning? && !@method.is_negated?
            Permission.grant(@method.action, @method.args)
          when
            Permission.deny(@method.action, @method.args)
          end
        else
          method_missing_without_permissions(name, *args)
        end
      end
      
      module ClassMethods
      end
    end
    
    module PermissionMixin
      def self.included(base)
        base.send(:extend, ClassMethods)
        base.belongs_to :accessible, :polymorphic => true
        base.belongs_to :controllable, :polymorphic => true
        base.validates_presence_of :action, :controllable_id, :controllable_type
      end
      
      module ClassMethods
        def normalize_permission_action(action)
          return if action.to_s.strip.blank?
          
          @@action_aliases_hash ||= Permission::ACTION_ALIASES.inject({}) do |rv, a|
            a.last.each {|val| rv[val.to_sym] = a.first.to_s }
            rv
          end

          @@action_aliases_hash[action.to_sym] || action
        end
        
        def exposed_permissions
          Permission::EXPOSE_PERMISSIONS.collect {|v| "'#{v.to_s}'"}.join(', ')
        end

        def extract_perm_args(args)
          [args[0].to_s.camelize, args[1], args[2].to_s.camelize, args[3]]
        end

        def find_with_perm_args(action, *args)
          c_type, c_id, a_type, a_id = extract_perm_args(args)
          Permission.find(:first, :conditions => ["action = ? and controllable_type = ? and controllable_id = ? and (accessible_type = ? or accessible_type is null) and (accessible_id = ? or accessible_id is null)", action, c_type, c_id, a_type, a_id])
        end

        def check(action, args)
          !find_with_perm_args(action, *args).nil?
        end

        def grant(action, args)
          c_type, c_id, a_type, a_id = extract_perm_args(args)
          args = {:action => action, :controllable_type => c_type,
            :controllable_id => c_id, :accessible_type => a_type,
            :accessible_id => a_id}
          Permission.find(:first, :conditions => args) || Permission.create(args)
        end

        def deny(action, args)
          p = find_with_perm_args(action, *args)
          p.destroy if p
        end        
      end
    end
  end
end
