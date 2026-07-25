#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <limits.h>
#include <sys/stat.h>

static int selfpath(char buf[], const char * argv0) {
    if (argv0[0] == '/') {
        for (size_t i = 0U; ; i++) {
            buf[i] = argv0[i];

            if (buf[i] == '\0') {
                return i;
            }
        }
    }

    //////////////////////////////////

    size_t slashIndex = 0U;

    for (size_t i = 0U; ; i++) {
        if (argv0[i] == '\0') {
            break;
        }

        if (argv0[i] == '/') {
            slashIndex = i;
        }
    }

    if (slashIndex > 0) {
        if (getcwd(buf, PATH_MAX) == NULL) {
            perror(NULL);
            return -1;
        }

        size_t n;

        for (n = 0U; buf[n] != '\0'; n++);

        buf[n] = '/';

        buf += n + 1;

        for (size_t i = 0U; ; i++) {
            buf[i] = argv0[i];

            if (buf[i] == '\0') {
                return (n + i);
            }
        }
    }

    //////////////////////////////////

    const char * p = getenv("PATH");

    if (p == NULL) {
        return -2;
    }

    if (p[0] == '\0') {
        return -3;
    }

    //////////////////////////////////

    struct stat st;

    char pathBuf[PATH_MAX];

    char * q;

    size_t i;
    size_t n;

loop:
    if (p[0] == '\0') {
        return 0;
    }

    if (p[0] == ' ' || p[0] == ':') {
        p++;
        goto loop;
    }

    //////////////////////////////////

    for (i = 0U; ; i++) {
        pathBuf[i] = p[i];

        if (p[i] == '\0') {
            break;
        }

        if (p[i] == ':') {
            pathBuf[i] = '\0';
            break;
        }
    }

    //////////////////////////////////

    if ((stat(pathBuf, &st) == 0) && S_ISDIR(st.st_mode)) {
        q = &pathBuf[i];

        q[0] = '/';

        q++;

        for (size_t j = 0U; ; j++) {
            q[j] = argv0[j];

            if (q[j] == '\0') {
                n = i + j + 1U;
                break;
            }
        }

        if (access(pathBuf, X_OK) == 0) {
            for (size_t j = 0U; j < n; j++) {
                buf[j] = pathBuf[j];
            }

            buf[n] = '\0';

            return n;
        }
    }

    //////////////////////////////////

    p += i;

    if (p[0] == ':') {
        p++;
        goto loop;
    }

    return 0;
}

int main(int argc, char* argv[]) {
    char pathBuf[PATH_MAX];

    if (selfpath(pathBuf, argv[0]) <= 0) {
        perror(NULL);
        return 1;
    }

    ////////////////////////////////////////////////////

    char selfExePath[PATH_MAX];

    if (realpath(pathBuf, selfExePath) == NULL) {
        perror(pathBuf);
        return 2;
    }

    ////////////////////////////////////////////////////

    size_t slashIndex = 0U;

    for (size_t i = 0U; i < PATH_MAX; i++) {
        if (selfExePath[i] == '\0') {
            break;
        }

        if (selfExePath[i] == '/') {
            slashIndex = i;
        }
    }

    ////////////////////////////////////////////////////

    selfExePath[slashIndex] = '\0';

    const char * selfDirPath = selfExePath;

    ////////////////////////////////////////////////////

    char perlExeFilePath[PATH_MAX];

    int ret = snprintf(perlExeFilePath, PATH_MAX, "%s/perl.exe", selfDirPath);

    if (ret < 0) {
        perror(NULL);
        return 3;
    }

    ////////////////////////////////////////////////////

#ifdef SCRIPT_MODE
    size_t slashIndex2 = 0U;

    for (size_t i = 0U; i < PATH_MAX; i++) {
        if (pathBuf[i] == '\0') {
            break;
        }

        if (pathBuf[i] == '/') {
            slashIndex2 = i;
        }
    }

    const char * cmdName = pathBuf + slashIndex2 + 1;

    char perlScriptFilePath[PATH_MAX];

    ret = snprintf(perlScriptFilePath, PATH_MAX, "%s/%s.pl", selfDirPath, cmdName);

    if (ret < 0) {
        perror(NULL);
        return 4;
    }
#endif


#ifdef __linux__
    char libraryPath[PATH_MAX];

    ret = snprintf(libraryPath, PATH_MAX, "%s/runtime", selfDirPath);

    if (ret < 0) {
        perror(NULL);
        return 5;
    }

    ////////////////////////////////////////////////////

    char dynamicLoaderPath[PATH_MAX];

    ret = snprintf(dynamicLoaderPath, PATH_MAX, "%s/ld-linux-x86-64.so.2", libraryPath);

    if (ret < 0) {
        perror(NULL);
        return 6;
    }

    ////////////////////////////////////////////////////

    selfExePath[slashIndex] = '/';

#ifdef SCRIPT_MODE
    int n = 7;
#else
    int n = 6;
#endif

    char* args[argc + n];

    args[0] = dynamicLoaderPath;
    args[1] = (char*)"--library-path";
    args[2] = libraryPath;
    args[3] = (char*)"--argv0";
    args[4] = selfExePath;
    args[5] = perlExeFilePath;

#ifdef SCRIPT_MODE
    args[6] = perlScriptFilePath;
#endif

    for (int i = 1; i < argc; i++) {
        args[n++] = argv[i];
    }

    args[n] = NULL;

    for (int i = 0; ; i++) {
        if (args[i] == NULL) break;
        puts(args[i]);
    }

    execv (dynamicLoaderPath, args);
    perror(dynamicLoaderPath);
#else
#ifdef SCRIPT_MODE
    char* args[argc + 2];

    args[0] = perlExeFilePath;
    args[1] = perlScriptFilePath;

    int n = 2;

    for (int i = 1; i < argc; i++) {
        args[n++] = argv[i];
    }

    args[n] = NULL;

    execv (perlExeFilePath, args);
    perror(perlExeFilePath);
#else
    argv[0] = perlExeFilePath;

    execv (perlExeFilePath, argv);
    perror(perlExeFilePath);
#endif

#endif

    return 255;
}
