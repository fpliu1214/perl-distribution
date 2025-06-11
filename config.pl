my $lddlflags = '-bundle -undefined dynamic_lookup';

my $coredir = relocate_inc('.../../lib/5.40.0/darwin-thread-multi-2level/CORE');

my $installprefix = relocate_inc('.../..');

my $perlpath = relocate_inc('.../perl');

######################################

my $cc = $ENV{CC_FOR_BUILD};

if (not defined $cc or $cc eq '') {
    $cc = $ENV{CC};
}

if (not defined $cc or $cc eq '') {
    $cc = "/usr/bin/cc";
}

######################################

my $ccflags = $ENV{CFLAGS_FOR_BUILD};

if (not defined $ccflags or $ccflags eq '') {
    $ccflags = $ENV{CFLAGS};
}

if (not defined $ccflags) {
    $ccflags = "";
}

######################################

my $cppflags = $ENV{CPPFLAGS_FOR_BUILD};

if (not defined $cppflags or $cppflags eq '') {
    $cppflags = $ENV{CPPFLAGS};
}

if (not defined $cppflags or $cppflags eq '') {
    $cppflags  = "-I$coredir";
} else {
    $cppflags .= " -I$coredir";
}

######################################

my $ldflags = $ENV{LDFLAGS_FOR_BUILD};

if (not defined $ldflags or $ldflags eq '') {
    $ldflags = $ENV{LDFLAGS};
}

if (not defined $ldflags or $ldflags eq '') {
    $ldflags  = "-L$coredir";
} else {
    $ldflags .= " -L$coredir";
}

######################################

