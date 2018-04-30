# Pathways into Darkness Maps and Save Inspector

This is the source code of the site at:

http://pid.whpress.com/

Learn more about Pathways into Darkness, a game released by Bungie Software in 1993, at:

http://pid.bungie.org/

### Requirements

This is a Perl-based web application, running under Apache's mod_cgid and MySQL/MariaDB.

The following non-core Perl modules are used:

* CGI
* DBD::mysql
* DBI
* HTML::Entities
* Image::Magick (during initial setup only)
* JSON
* String::CRC32
* XML::Simple
* XML::Writer

To enable error notifications via email, see `modules/page.subs`.

### Setup

The main steps are:

1. **Add binary data** - Pathways into Darkness is not freely distributable, so you'll have to find your own copy of the app and data. There are two full releases and two demo releases; you will need to make some edits if you don't have all versions. See the `resources` directory for exactly what to do with the data.

2. **Create a database** - Add the connection info to `modules/db.ph`. Also, manually load the structure from `offline/schema.sql`.

3. **Run the setup script** - `cd offline; bash initialize.sh`

4. **Configure your webserver** - You don't need to serve the `offline` or `resources` directories. You do need to serve the `full20`, etc. directories created during the setup process. Apache `.htaccess` files are included, but YMMV based on version and the base permissions.
