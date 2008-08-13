require 'permissable'

ActiveRecord::Base.send(:include, Jamlab::Permissable::Mixin)