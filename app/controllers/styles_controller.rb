# coding: UTF-8
class StylesController < ApplicationController
  def index
    engine= Sass::Engine.new(File.read("public/stylesheets/sass/colors.sass"), syntax: :sass, load_paths: ["app/stylesheets"])
    environment= Sass::Environment.new
    engine.to_tree.children.each do | node |
      next unless node.kind_of? Sass::Tree::VariableNode
      node.perform environment
    end

    @sass_vars= environment.instance_variable_get("@vars").reject{|k| k == "important" }
  end
end
