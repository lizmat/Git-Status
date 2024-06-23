unit class Git::Status;

has IO() $.directory = $*CWD.absolute;
has str  @.modified  is built(False); # 1
has str  @.added     is built(False); # 2
has str  @.deleted   is built(False); # 3
has str  @.renamed   is built(False); # 4
has str  @.copied    is built(False); # 5
has str  @.updated   is built(False); # 6
has str  @.untracked is built(False); # 7
# dirty means something is the opposite of clean, i.e., a
# git status that would cause App::Mi6 to abort
has Bool $.clean = True;

method TWEAK() {
    indir $!directory, {
        # By default, the git command is using version 1 format:
        # XY PATH
        # XY ORIG_PATH -> PATH

        my $proc := run <git status --porcelain>, :out;

        for $proc.out.lines {
            my %h; # the two XY chars which may be the same.
                   # spaces are ignored
            my $path := .substr(3);
            my @c = $_.comb[0..1];
            for @c {
                # skip a space, it means unmodified, so we ignore it
                next if $_ eq ' ';
                %h{$_} = 1;
            }
            for %h.keys {
                # There are 7 non-space characters indicating a
                # "dirty" repository plus 1 if 'Ignored' files are of
                # interest (does not affect the "clean" status)
                when $_ eq 'M' {
                    # 1 - Modified
                    $!clean = False;;
                    @!modified.push: $path;
                }
                when $_ eq 'A' {
                    # 2 - Added
                    $!clean = False;;
                }
                when $_ eq 'D' {
                    # 3 - Deleted
                    $!clean = False;;
                    @!deleted.push: $path;
                }
                when $_ eq 'R' {
                    # 4 - Renamed
                    $!clean = False;;
                }
                when $_ eq 'C' {
                    # 5 - Copied
                    $!clean = False;;
                }
                when $_ eq 'U' {
                    # 6 - Updated, but Unmerged
                    $!clean = False;;
                }
                when $_ eq '?' {
                    # 7 - Untracked path
                    $!clean = False;;
                    @!untracked.push: $path;
                }
                # the following are N/A for "dirty" status
                when $_ eq '!' {
                    # 8 - Ignored path
                    # info only, NOT "dirty"
                    ; # no report
                }
                default {
                    note "Unrecognized: '$_'";
                }
            }
        }
    }
}

method is-clean() {
    self.clean.so
}

method gist() {
    my str @parts;
    my sub seen($title, @push) {
        @parts.push: $title;
        @parts.push: "  $_" for @push;
        @parts.push: "";
    }

    seen("Modified:",  @!modified)  if @!modified;  # 1
    seen("Added:",     @!added)     if @!added;     # 2
    seen("Deleted:",   @!deleted)   if @!deleted;   # 3

    seen("Renamed:",   @!renamed)   if @!renamed;   # 4
    seen("Copied:",    @!copied)    if @!copied;    # 5
    seen("Updated:",   @!updated)   if @!updated;   # 6
    seen("Untracked:", @!untracked) if @!untracked; # 7

    @parts.prepend: self.^name ~ ":", "  $!directory", "" if @parts;

    @parts.join: "\n"
}

=begin pod

=head1 NAME

Git::Status - obtain status of a git repository

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

Git::Status provides a simple way to obtain the status of a git
repository using the C<git status --porcelain> command (version 1) and
simplifying the results to indicate whether the repository is 'clean'
or 'dirty'.  This module's primary purpose is to determine whether any
action is required to satisfy further use by C<App::Mi6> or to
indicate user intervention is necessary.

Note the full output of C<git status --porcelain> is quite complex and
completely identifies the situation with regards to both the index and
the working tree (a complex task with many possible combinations). See
the C<git-status> man page for details.

=head1 PARAMETERS

=head2 directory

The directory of the git repository.  Can be specified as either an C<IO::Path>
object, or as a string.  Defaults to C<$*CWD>.  It should be readable.

=head1 METHODS

=head2 is-clean

Returns the value of the $!clean variable which is True for a "clean"
Git directory.

=head2 gist

A text representation of the object, empty string if there were no
modified, added, deleted, renamed, copied, updated, or untracked
files.

=head2 added

The paths of files that have been added.

=head2 deleted

The paths of files that have been deleted.

=head2 directory

The directory of the repository, as an C<IO::Path> object.

=head2 modified

The paths of files that have been modified.

=head2 untracked

The paths of files that are not tracked yet.

=head2 newfile

The paths of files that are new.

=head2 renamed

The paths of files that are renamed.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Git-Status .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2021, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
