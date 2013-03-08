knife-tagbulk
=============

A plugin for Chef::Knife that allows bulk tag operations (either creation or deletion) using standard Chef search queries

Manual installation
-------------------

Copy all .rb scripts from lib/chef/knife to your ~/.chef/plugins/knife directory.

Installation via RubyGems
-------------------------

knife-tagbulk is available on rubygems.org - if you have that source in your gemrc, you can simply use:

    gem install knife-tagbulk

What it does
------------

The plugin offers 2 actions:

* knife tag bulk create QUERY TAG1 TAG2 ...

Use `create` and specify a standard Chef query like `roles:webserver AND chef_environment:prod` and a set of space-separated
tags (like `maintenance offline`) in order to tag all nodes retrieved from the search with the specified tags.

* knife tag bulk delete QUERY TAG1 TAG2 ... (options)

Use `delete` and specify a standard Chef query like `roles:webserver AND chef_environment:prod` and a set of space-separated
tags (like `maintenance offline`) in order to remove those tags from all nodes retrieved from the search.

There is also the possiblity to use Regular Expressions to remove tags based on them. Just specify the `-r` switch and then
describe the tags in Regular Expression format. Since there is great posbbility that your shell may escape them though, it's
best if you enclose them in quotes. Specifying `-y` in addition to `-r` will skip delete confirmation.

An example RE-based command is formed like this:

    knife tag bulk delete 'roles:web_old_infrastructure' 'version-deployed-.*' -r -V

Things to notice
----------------

* I am a console color freak so the plugin uses nice colors. Use --no-color to disable them!

* If you are looking for more information on the actions of the plugin, just turn on verbose output (via `-V` or `--verbose`).

License and Author
------------------

* Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)

* Copyright:: 2013, Panagiotis Papadomitsos

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
