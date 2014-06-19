require 'nokogiri'

module Aleph
  class Base
    def self.config
      Aleph::config
    end

    def config
      Aleph::config
    end

    def parse(nodes)
      parse_objects('Hash', nodes)
    end

    def parse_objects(klass, nodes)
      all = Array.new
      nodes.each do |top|
        result = klass.constantize.new
        top.element_children.each do |node|
          #logger.info "Node: #{node.name}, #{node.type}, #{node.element_children}"
          if node.element_children.empty?
            result[node.name] = node.text
          end
        end
        all << result
      end
      all
    end

    def logger
      Rails.logger
    end
  end
end
