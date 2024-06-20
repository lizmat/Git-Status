unit class Git::Status;

has IO() $.directory = $*CWD.absolute;
has str  @.added     is built(False);
has str  @.deleted   is built(False);
has str  @.modified  is built(False);
has str  @.untracked is built(False);
has str  @.renamed   is built(False);

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
                next if $_ eq ' ';
                %h{$_} = 1;
            }
            for %h.keys {
                # there are 10 known non-space characters
                when $_ eq 'M' {
                    # Modified  
                }
                when $_ eq 'A' {
                    # Added
                }
                when $_ eq 'D' {
                    # Deleted
                }
                when $_ eq 'R' {
                    # Renamed
                }
                when $_ eq 'C' {
                    # Copied
                }
                when $_ eq 'U' {
                    # Updated, but Unmerged
                }
                when $_ eq '?' {
                    # Untracked path
                }
                when $_ eq '!' {
                    # Ignored path
                }
            }

            if .starts-with('?? ') {
                @!untracked.push: $path;
            }
            elsif .starts-with(' D ') {
                @!deleted.push: $path;
            }
            elsif .substr-eq('M', 1) {
                @!modified.push: $path;
                @!added.push($path) if .starts-with('A');
            }
            elsif .starts-with('A') {
                @!added.push($path);
            }
            elsif .starts-with('R') {
                @!renamed.push: $path;
            }
            else {
                note "Unrecognized: '$_'";
            }
        }
    }
}

method gist() {
    my str @parts;
    my sub seen($title, @push) {
        @parts.push: $title;
        @parts.push: "  $_" for @push;
        @parts.push: "";
    }

    seen("Added:",     @!added)     if @!added;
    seen("Deleted:",   @!deleted)   if @!deleted;
    seen("Modified:",  @!modified)  if @!modified;
    seen("New:",       @!newfile)   if @!newfile;
    seen("Renamed:",   @!renamed)   if @!renamed;
    seen("Untracked:", @!untracked) if @!untracked;
    
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

if $status.newfile -> @newfile {
    say "Newfile:";
    .say for @newfile;
}

if $status.renamed -> @renamed {
    say "Renamed:";
    .say for @renamed;
}

if $status.untracked -> @untracked {
    say "Untracked:";
    .say for @untracked;
}

=end code

=head1 DESCRIPTION

Git::Status provides a simple way to obtain the status of a git repository.

=head1 PARAMETERS

=head2 directory

The directory of the git repository.  Can be specified as either an C<IO::Path>
object, or as a string.  Defaults to C<$*CWD>.  It should be readable.

=head1 METHODS

=head2 added

The paths of files that have been added.

=head2 deleted

The paths of files that have been deleted.

=head2 directory

The directory of the repository, as an C<IO::Path> object.

=head2 gist

A text representation of the object, empty string if there were no added,
deleted or modified files.

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
