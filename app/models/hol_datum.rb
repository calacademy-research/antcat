# coding: UTF-8
class HolDatum < ActiveRecord::Base
  attr_accessible :name,
                  :lsid,
                  :tnid,
                  :tnuid,
                  :author,
                  :rank,:status,
                  :is_valid,
                  :fossil,
                  :num_spms,
                  :many_antcat_references,
                  :many_hol_references
end
