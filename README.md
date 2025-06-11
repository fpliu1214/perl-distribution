# perl-distribution
A self-contained and relocatable Perl distribution

## change

To make perl protable, I change some behaver. I allow user set their `cc`, `cflags`, `cppflags`, `ldflags` via environment variable when creating perl modules.

|||
|-|-|
|`cc`|`CC_FOR_BUILD` `CC`|
|`cflags`|`CFLAGS_FOR_BUILD` `CFLAGS`|
|`cppflags`|`CPPFLAGS_FOR_BUILD` `CPPFLAGS`|
|`ldflags`|`LDFLAGS_FOR_BUILD` `LDFLAGS`|

`FOO_FOR_BUILD` take precedence over `FOO`

For details, please see https://github.com/leleliu008/perl-distribution/blob/master/config.pl
