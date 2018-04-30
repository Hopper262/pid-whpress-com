# Setup procedure

1. Add binary files to `../resources` directory (see documentation there).

2. Create a MySQL database for use by the website. (Other compatible databases may be used, but have not been tested.) Make sure you've installed the appropriate Perl DBD driver.

3. Populate the database by loading the `schema.sql` file.

4. Edit `../modules/db.ph` with the database connection information.

5. Run `initialize.sh` from this directory.
