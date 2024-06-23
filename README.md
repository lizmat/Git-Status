[![Actions Status](https://github.com/lizmat/Git-Status/workflows/test/badge.svg)](https://github.com/lizmat/Git-Status/actions)

NAME
====

Git::Status - obtain status of a git repository

SYNOPSIS
========

```raku
use Git::Status;

my $status := Git::Status.new(:$directory);

if $status.is-clean {
    say "Is clean";
}

if $status.modified -> @modified {
    say "Modified:";
    .say for @modified;
}

if $status.added -> @added {
    say "Added:";
    .say for @added;
}

if $status.deleted -> @deleted {
    say "Deleted:";
    .say for @deleted;
}

if $status.renamed -> @renamed {
    say "Renamed:";
    .say for @renamed;
}

if $status.copied -> @copied {
    say "Copied:";
    .say for @copied;
}

if $status.updated -> @updated {
    say "Updated:";
    .say for @updateded;
}

if $status.untracked -> @untracked {
    say "Untracked:";
    .say for @untracked;
}
```

DESCRIPTION
===========

Git::Status provides a simple way to obtain the status of a git repository using the `git status --porcelain` command (version 1) and simplifying the results to indicate whether the repository is 'clean' or 'dirty'. This module's primary purpose is to determine whether any action is required to satisfy further use by `App::Mi6` or to indicate user intervention is necessary.

Note the full output of `git status --porcelain` is quite complex and completely identifies the situation with regards to both the index and the working tree (a complex task with many possible combinations). See the `git-status` man page for details.

PARAMETERS
==========

directory
---------

The directory of the git repository. Can be specified as either an `IO::Path` object, or as a string. Defaults to `$*CWD`. It should be readable.

METHODS
=======

is-clean
--------

Returns the value of the $!clean variable which is True for a "clean" Git directory.

gist
----

A text representation of the object, empty string if there were no modified, added, deleted, renamed, copied, updated, or untracked files.

added
-----

The paths of files that have been added.

deleted
-------

The paths of files that have been deleted.

directory
---------

The directory of the repository, as an `IO::Path` object.

modified
--------

The paths of files that have been modified.

untracked
---------

The paths of files that are not tracked yet.

newfile
-------

The paths of files that are new.

renamed
-------

The paths of files that are renamed.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Git-Status . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2021, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

