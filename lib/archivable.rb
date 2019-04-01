module Archivable
  def self.included(base)
    base.class_eval '@archivable_mixin_configs = {}'
    base.singleton_class.send(:attr_reader, :archivable_mixin_configs)

    base.extend(ClassMethods)
  end

  module ClassMethods
    def is_archivable(configs = {})
      @archivable_mixin_configs = {
        field_name: :archived_at,
        archived_term: :discontinued,
        not_archived_term: :existent,
        archival_validator: nil,
        restoration_validator: nil,
      }.merge! configs

      cfg = @archivable_mixin_configs

      # unless cfg[:field_name].to_s == "is_#{cfg[:archived_term]}"
      #   class_eval "legacy_attr_whitelist :#{cfg[:field_name]}, :is_#{cfg[:archived_term]}"
      # end

      unless cfg[:field_name].to_s == "#{cfg[:archived_term]}_at"
        class_eval "alias_attribute :#{cfg[:archived_term]}_at, :#{cfg[:field_name]}"
      end

      define_method "#{cfg[:archived_term]}?" do
        !self[cfg[:field_name]].nil?
      end

      define_method "#{cfg[:not_archived_term]}?" do
        self[cfg[:field_name]].nil?
      end

      define_method "is_#{cfg[:archived_term]}=" do |bool|
        return if send("#{cfg[:archived_term]}?") == Bool.true_enough?(bool)
        validator = Bool.true_enough?(bool) ? cfg[:archival_validator] : cfg[:restoration_validator]
        if validator.nil? || (validator.class == Proc ? validator.call : send(validator))
          self[cfg[:field_name]] = Bool.true_enough?(bool) ? Time.now : nil
        end
      end

      define_singleton_method "#{cfg[:archived_term]}" do
        where("#{table_name}.#{cfg[:field_name]} NOT NULL")
      end

      define_singleton_method "#{cfg[:not_archived_term]}" do
        where("#{table_name}.#{cfg[:field_name]} IS NULL")
      end
    end
  end
end


class ActiveRecord::Base
  include Archivable
end
