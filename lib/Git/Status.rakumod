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

        my $proc := run <git status --porcelain>, :out, :err;

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

# vim: expandtab shiftwidth=4
