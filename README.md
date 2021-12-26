NAME
====

Git::Status - obtain status of a git repository

SYNOPSIS
========

```raku
use Git::Status;

my $status := Git::Status.new(:$directory);

if $status.added -> @added {
    say "Added:";
    .say for @added;
}

if $status.deleted -> @deleted {
    say "Deleted:";
    .say for @deleted;
}

if $status.modified -> @modified {
    say "Modified:";
    .say for @modified;
}

if $status.untracked -> @untracked {
    say "Untracked:";
    .say for @untracked;
}
```

DESCRIPTION
===========

Git::Status provides a simple way to obtain the status if a git repository.

PARAMETERS
==========

directory
---------

The directory of the git repository. Can be specified as either an `IO::Path` object, or as a string. Defaults to `$*CWD`. It should be readable.

METHODS
=======

added
-----

The paths of files that have been added.

deleted
-------

The paths of files that have been deleted.

directory
---------

The directory of the repository, as an `IO::Path` object.

gist
----

A text representation of the object, empty string if there were no added, deleted or modified files.

modified
--------

The paths of files that have been modified.

untracked
---------

The paths of files that are not tracked yet.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Git-Status . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

