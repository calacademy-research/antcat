# coding: UTF-8
class Update < ActiveRecord::Base
    attr_accessible :name, :record_id, :class_name, :field_name, :before, :after
end
