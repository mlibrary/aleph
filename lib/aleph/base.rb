# frozen_string_literal: true

require 'nokogiri'

module Aleph
  class Base
    def self.config
      Aleph.config
    end

    def config
      Aleph.config
    end

    def parse(nodes)
      parse_objects(Hash, nodes)
    end

    def parse_objects(klass, nodes)
      all = []
      nodes.each do |top|
        result = klass.new
        top.element_children.each do |node|
          result[node.name] = node.text if node.element_children.empty?
        end
        all << result
      end
      all
    end
  end
end
