*perl-h2xs.txt*      For Vim version 6.1.  Last change: 2002 Oct 30th

              Perl create a new .pm via h2xs

==============================================================================

The Perl_h2xs.vim plugin is a plugin that allows you to automate the process
of perl module creation. Writing Perl modules with the recommended structure
can be time consuming when you do it by hand. But as we're using computers
everything can be automated. This Vim plugin makes it a little easier to
convert a request to start editing a new .pm file into a request to create a
skeleton module and start editing the skeleton file for that module. It can
even check it into your CVS server if you so desire.... :)

The zip file contains 3 files:


  README_h2xs.txt
  ftplugin/perl_h2xs.vim
  doc/perl_h2xs.txt

unzip this file in your local vim directory (.vim or vim\vimfiles) and keep
the directory structure. You should then start Vim and add the help file to
your local help docs using the command:

  :helptags {dir}

I.e.

  :helptags .vim/doc
  :helptags vim61\vimfiles\doc

(correct as appropriate for your install, I only know about UNIX & W2K)

You can then use the plugin by starting Vim with a .pm extension:

unix:
  vim Test::Bob.pm
  vim Test/Bob.pm

w32:
 gvim Test\Bob.pm

You can even plonk the files into a certain directory by specifying a directory
using normal directory location and specifying the module in Perl notation.

 vim /usr/local/src/perl_modules/Test::Bob.pm
 gvim c:\perl\locallib\Test::Bob.pm

and you'll be fine. You can even specify:

 vim /usr/local/src/perl_modules/Test.pm

And the program will see it as "Test.pm" in the directory
/usr/local/src/perl_modules - that is, assuming you have those directories. If
you don't and you only have, say, /usr/local/src, then it will think that
you're trying to write the module 'perl_modules/Test.pm'. Unfortunately you'll
have to deal with this and not be stupid because Vim has not support for

 if(has('psychic_powers'))


CHANGE LOG:

Changes since v0.5

 * Fixed error in substitute() regexp for calculating module filename. Was
   turning Eg/Eg1/Test => Eg/Eg1/Test/Eg1/Test.pm, now correctly produces
   Eg/Eg1/Test/Test.pm

 * Filename of module calculated before asking user any questions. This
   allows us to test if this file exists and if it does to ask the user if
   the meant to edit the module filename. If so a user can type:

    vim Eg::Test.pm

   to run h2xs which creates the file, then quit out and find that

    !v

   (which runs the same command "vim Eg::Test.pm") will edit the newly created
   module. Previously doing this would cause the program to see that the file
   Eg::Test.pm didn't exist then ask the user to create the module and then fail
   because it already existed. Now it finds if the file Eg/Test/Test.pm exists,
   asks if they want to edit it if it does, if not it asks if they want to create
   it.

 * Introduction  variable g:perl_h2xs_askedit which overrides the above prompting
   to edit if the module has already been created.

 * Prints prompt before "cvs add/import". Previous the password prompt sent by
   cvs was lost and the program just seemed to hang until you hit enter 3 times :p

   
