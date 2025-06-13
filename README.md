# perl-distribution
A self-contained and relocatable Perl distribution

## changes

**1. crypt.h is included in the distribution for Linux**

**2. user can set `cc` `cflags` `cppflags` `ldflags` via environment variable when building perl modules**

|||
|-|-|
|`cc`|`CC_FOR_BUILD` `CC`|
|`cflags`|`CFLAGS_FOR_BUILD` `CFLAGS`|
|`cppflags`|`CPPFLAGS_FOR_BUILD` `CPPFLAGS`|
|`ldflags`|`LDFLAGS_FOR_BUILD` `LDFLAGS`|

`FOO_FOR_BUILD` take precedence over `FOO`

For details, please see https://github.com/leleliu008/perl-distribution/blob/master/config.pl
