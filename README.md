Monster Remote (gem: monster_remote)
====================================

#What is this?
A gem to help you publish your [jekyll](http://jekyllrb.com) blog via
ftp (or any other "plugable" remote machine connection provider).

#How is this?
After install the gem

  gem install monster_remote

A new executable is gonna be at your service: `monster_remote`.

#Stablishing connection
Enter the jekyll blog root path and type:

  monster --ftp -s [your_server_address] -u [your_user_here]

The --ftp option is default, this first options is about which type of
connection the monster should try to stablish. You will be prompted for
your password.

You can reduce the size of the command by configuring some of these
informations on your jekyll configuration file:

  monster:
    remote:
      host: xpto.com
      user: omg_my_user

Monster will rely on this configurations if you execute it like this:

  monster --ftp

###Plugin a new connection provider
