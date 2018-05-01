This directory holds binary data from each public release of Pathways into Darkness. This data is not distributed here for copyright reasons.

To initialize the site, create four subfolders:

* `demoA1` - The initial demo release
* `demo20` - The final demo release
* `full11` - The full release of Pathways into Darkness 1.1
* `full20` - The full release of Pathways into Darkness 2.0

Populate each folder with three files from the appropriate version:

* `app.rsrc` - resource fork of the "Pathways into Darkness" application
* `map.data` - data fork of the "Maps" file
* `shapes.rsrc` - resource fork of the "Shapes" file

These files should be raw dumps of the forks; do not use MacBinary or other encoding.

Once you have initialized the database from the `offline` directory (see documentation there), these binary files are no longer used and may be deleted.
