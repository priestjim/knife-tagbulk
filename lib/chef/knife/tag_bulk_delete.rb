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

      banner 'knife tag bulk delete QUERY TAG ... (options)'
      category 'tag'

      option :regex,
        :short => '-r',
        :long => '--regex-match',
        :description => 'Specify a tag regular expression to match to instead of exact tags to delete',
        :boolean => true,
        :default => false

      option :yes,
        :short => '-y',
        :long => '--yes',
        :description => 'Do not prompt for delete confirmation when specifying a tag regular expression match',
        :boolean => true,
        :default => false

      def run
        @query = @name_args.shift
        @tags = @name_args

        if @query.nil? || @query.empty? || @tags.nil? || @tags.empty?
          show_usage
          ui.fatal('You must specify a valid Chef node search query and at least one tag.')
          exit 1
        end

        escaped_query = URI.escape(@query,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        query = Chef::Search::Query.new
        node_items = []
        node_count = 0
        begin
          res = query.search(:node, escaped_query)
          node_items = res.first.map{ |node| node.name }.sort
          node_count = res.last
          nodes_found(node_count)
          if node_count > 0
            if config[:regex]
              unless config[:yes]
                confirm = ui.ask_question(
                  ui.color("\u2192  Deleting tags based on regulard expressions is a potentially dangerous operation. Are you sure you want to continue? ", [:bold, :red]),
                  {:default => 'Y'}
                )
                if not confirm.match(/[Yy][Ee]?[Ss]?/)
                  ui.fatal('Did not confirm destructive operation. Exiting...')
                  exit 1
                end
              end
              rtags = @tags.map { |rtag| Regexp.new(rtag) }
            end
            node_items.each do |node_name|
              node = Chef::Node.load(node_name)
              tags_to_remove = Array.new              
              if config[:regex]                
                tags_to_remove = node.tags.map do |ntag|
                  rtags.map do |utag|
                    break ntag if ntag.match(utag)
                  end
                end.flatten.compact.uniq
              else
                tags_to_remove = @tags
              end
              if (node.tags & tags_to_remove).size == 0
                tags_not_present(node_name, @tags)
                next
              end
              tags_to_remove.each { |tag| node.tags.delete(tag) }
              node.save
              tags_successfully_deleted(node_name, tags_to_remove)
              if config[:verbosity] > 0
                verbose_node_tag_information(node_name, node.tags)
              end
            end
          end
        rescue Net::HTTPServerException => e
          msg = Chef::JSONCompat.from_json(e.response.body)['error'].first
          ui.fatal("An error occurred: #{msg}")
          exit 1
        rescue RegexpError => e
          ui.fatal("Invalid Regular expression given: #{e.message}")
        end      
      end

      def nodes_found(node_count)
        ui.info(
          ui.color("\u2192  ", [:bold, :green]) +
          ui.color(node_count.to_s, [:bold, :yellow]) +
          ui.color(' node(s) found.', [:bold, :white])
        )      
      end

      def tags_not_present(node_name, tags)
        ui.info(
          ui.color("\u2714  ", [:bold, :green]) +
          ui.color("Tag(s) ", [:bold, :white]) + 
          ui.color("[#{tags.join(', ')}]", [:bold, :yellow]) + 
          ui.color(" not present on node ", [:bold, :white]) +
          ui.color("[#{node_name}]", [:bold, :yellow]) +
          ui.color(". Skipping...", [:bold, :white])
        )      
      end

      def tags_successfully_deleted(node_name, tags)
        ui.info(
          ui.color("\u2714  ", [:bold, :green]) +
          ui.color("Successfully deleted tag(s) ", [:bold, :white]) + 
          ui.color("[#{tags.join(', ')}]", [:bold, :yellow]) + 
          ui.color(" from node ", [:bold, :white]) +
          ui.color("[#{node_name}]", [:bold, :yellow])
        )        
      end

      def verbose_node_tag_information(node_name, tags)
        ui.info(
          ui.color("\u2192  ", [:bold, :green]) +
          ui.color('Node ', [:bold, :white]) +
          ui.color("[#{node_name}]", [:bold, :yellow]) +
          ui.color(' is now tagged with ', [:bold, :white]) +
          ui.color("[#{tags.join(', ')}]", [:bold, :yellow])
        )
      end

    end
  end
end
