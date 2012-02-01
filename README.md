Monster Remote (gem: monster_remote)
====================================

#What is this?
A gem to help you publish your [jekyll](http://jekyllrb.com) blog via
ftp (or any other "plugable" remote machine connection provider).

#How is this?
After install the gem

    gem install monster_remote

A new executable is gonna be at your service: `monster_remote`.

##Syncing
Enter the jekyll blog root path and type:

    monster_remote [--ftp] -s 'your_server_address' -u 'your_user_here'

The --ftp option is default, you could create you own connection
provider if you need it.

You will be prompted for your password. To reduce the size of the
command by configuring some of these informations on your jekyll
configuration file:

    monster:
      remote:
        host: xpto.com
        user: omg_my_user

Monster will rely on this configurations if you execute it without -s
and -u params like this:

  monster_remote

##Filtering specific files
A filter is an object which `respond_to? :filter`, you can stack
filters within the synchronization execution. The code to do that
has to stay on a `monster_config.rb` or a `config.rb`, create
this file on the root directory of your jekyll site:

```ruby
# monster_config.rb

Monster::Remote::add_filter(my_filter)
```

`monster_remote` is shipped with a "name_based_filter", if you want to
reject specific files or directories based on the name, you could do
something like these:

```ruby
# monster_config.rb

my_filter = Monster::Remote::Filters::NameBasedFilter.new
my_filter.reject /^.*rc/
my_filter.reject /^not_allowed_dir\//

Monster::Remote::add_filter(my_filter)
```

Note: the param to `#reject` can be a valid regex, so you could define
some fine grained rules here. The above example will reject any file
starting with a "." and ending with "rc", wich is pretty much any
"classic" configuration file that you have on your directory. Neither
"not_allowed_dir" gonna be synced. You could provide an array if you prefer:

```ruby
my_filter.reject [/^.*rc/, /ˆnot_allowed_dir\//]`
```

Or you could use a string:

```ruby
my_filter.reject ".my_secret_file"
```

If you need execute more specific or complex logic, you could use a "raw
filter". Just provides a block with the logic you need, an array with
the dir structure will be passed as argument and a filtered array should
be returned. Just files and dirs on the result array will be synced:

```ruby
my_custom_filter = Monster::Remote::Filters::Filter.new
my_custom_filter.reject lambda { |entries|
  # do whatever you need here, for example:
  entries.reject do |entry|
    entry =~ /^.*rc/ || entry =~ /^not_allowed_dir\//
  end
}

Monster::Remote::add_filter(my_custom_filter)
```

Since a filter is an object which `responds_to? :filter` you could
implement your filter in a class. The `#filter` will receive an array
with the list of files and dirs in given directory, you need to return a
new array with only the allowed files and dirs:

```ruby
class MyOMGFilter
  def filter(entries)
    // your logic here
    return new_filtered_array
  end
end
```

#Protocol Wrappers
A wrapper is an object with the following methods:

 * ::new=(driver=Net::FTP)
    - the class from the real connection objects will be generated
 * #open(host=nil, user=nil, password=nil, port=nil)
    - called when the synchrony starts
    - if a block is given, it will be yielded and two arguments will be
      passed to the block:
        - an object that responds_to? :create_dir, and responds_to?
          :copy_file. This object has an internal reference to the real
          connection
           - #create_dir(dir) - creates a dir on the remote path
           - #copy_file(from, to) - copies a file to the remote location
        - the real connection object (you can ignore the second argument if you want)
    - this method close the real connection before returns

Internally a wrapper will use a real "thing" (like the default Net::FTP)
to replicate the local dir structure to the remote dir.
