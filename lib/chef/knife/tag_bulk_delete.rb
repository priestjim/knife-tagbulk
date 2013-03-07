#
# Author:: Panagiotis Papadomitsos <pj@ezgr.net>
# Copyright:: Copyright (c) 2013, Panagiotis Papadomitsos
# License:: Apache License, Version 2.0
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'chef/knife'

class Chef
  class Knife
    class TagBulkDelete < Knife

      deps do
        require 'chef/node'
        require 'chef/search/query'
      end

      banner 'knife tag bulk delete QUERY TAG ...'
      category 'tag'

      def run
        @query = @name_args.shift
        @tags = @name_args

        if @query.nil? || @query.empty? || @tags.nil? || @tags.empty?
          show_usage
          ui.fatal('You must specify a valid Chef node search query and at least one tag.')
          exit 1
        end

        escaped_query = URI.escape(@query,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        q = Chef::Search::Query.new
        node_items = []
        node_count = 0
        begin
          res = q.search(:node, escaped_query)
          node_items = res.first.map { |node| node.name }
          node_count = res.last
          ui.info(
            ui.color("\u2192  ", [:bold, :green]) +
            ui.color(node_count.to_s, [:bold, :yellow]) +
            ui.color(' node(s) found.', [:bold, :white])
          )
          if node_count > 0
            node_items.each do |node_name|              
              node = Chef::Node.load(node_name)
              @tags.each { |tag| node.tags.delete(tag) }
              node.save
              ui.info(
                ui.color("\u2714  ", [:bold, :green]) +
                ui.color("Successfully deleted tag(s) ", [:bold, :white]) + 
                ui.color("[#{@tags.join(', ')}]", [:bold, :yellow]) + 
                ui.color(" from node ", [:bold, :white]) +
                ui.color("[#{node_name}]", [:bold, :yellow])
              )
              if config[:verbosity] > 0
                ui.info(
                  ui.color("\u2192  ", [:bold, :green]) +
                  ui.color('Node ', [:bold, :white]) +
                  ui.color("[#{node_name}]", [:bold, :yellow]) +
                  ui.color(' is now tagged with ', [:bold, :white]) +
                  ui.color("[#{node.tags.join(', ')}]", [:bold, :yellow])
                )
              end
            end
          end
        rescue Net::HTTPServerException => e
          msg = Chef::JSONCompat.from_json(e.response.body)['error'].first
          ui.fatal("An error occurred: #{msg}")
          exit 1
        end      
      end

    end
  end
end
