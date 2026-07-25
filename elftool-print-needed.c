#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <fcntl.h>

#include <sys/stat.h>
#include <sys/mman.h>

#include <elf.h>

int main(int argc, const char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <ELF-FILEPATH>\n", argv[0]);
        return 1;
    }

    if (argv[1][0] == '\0') {
        printf("Usage: %s <ELF-FILEPATH>, <ELF-FILEPATH> is unspecified.\n", argv[0]);
        return 2;
    }

    int fd = open(argv[1], O_RDONLY);

    if (fd == -1) {
        perror(argv[1]);
        return 3;
    }

    struct stat st;

    if (fstat(fd, &st) == -1) {
        perror(argv[1]);
        close(fd);
        return 4;
    }

    if (st.st_size < 52) {
        fprintf(stderr, "NOT an ELF file: %s\n", argv[1]);
        close(fd);
        return 100;
    }

    ///////////////////////////////////////////////////////////

    unsigned char a[5];

    ssize_t readBytes = read(fd, a, 5);

    if (readBytes == -1) {
        perror(argv[0]);
        close(fd);
        return 5;
    }

    if (readBytes != 5) {
        perror(argv[0]);
        close(fd);
        fprintf(stderr, "not fully read.\n");
        return 6;
    }

    ///////////////////////////////////////////////////////////

    // https://www.sco.com/developers/gabi/latest/ch4.eheader.html
    if ((a[0] != 0x7F) || (a[1] != 0x45) || (a[2] != 0x4C) || (a[3] != 0x46)) {
        fprintf(stderr, "NOT an ELF file: %s\n", argv[1]);
        close(fd);
        return 100;
    }

    ///////////////////////////////////////////////////////////

    void * p = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);

    if (p == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return 7;
    }

    close(fd);

    unsigned char * elf = (unsigned char *)p;

    ///////////////////////////////////////////////////////////

    switch (a[4]) {
        case ELFCLASS64: {
                Elf64_Ehdr * ehdr = (Elf64_Ehdr*)elf;
                Elf64_Phdr * phdr;

                int has = 0;

                for (Elf64_Half i = 0; i < ehdr->e_phnum; i++) {
                    phdr = (Elf64_Phdr*)(elf + ehdr->e_phoff + i * ehdr->e_phentsize);

                    if (phdr->p_type == PT_DYNAMIC) {
                        has = 1;
                        break;
                    }
                }

                if (has == 0) {
                    return 0;
                }

                const char * dynstr = NULL;

                Elf64_Dyn * dyn;

                for (size_t i = 0; i < 100; i++) {
                    dyn = (Elf64_Dyn*)(elf + phdr->p_offset + i * sizeof(Elf64_Dyn));

                    if (dyn->d_tag == DT_NULL) {
                        break;
                    }

                    if (dyn->d_tag == DT_STRTAB) {
                        dynstr = (const char *)elf + dyn->d_un.d_ptr;
                        break;
                    }
                }

                if (dynstr == NULL) {
                    return 1;
                }

                for (size_t i = 0; i < 100; i++) {
                    dyn = (Elf64_Dyn*)(elf + phdr->p_offset + i * sizeof(Elf64_Dyn));

                    if (dyn->d_tag == DT_NULL) {
                        break;
                    }

                    if (dyn->d_tag == DT_NEEDED) {
                        puts(dynstr + dyn->d_un.d_val);
                    }
                }
            }
            return 0;
        case ELFCLASS32: {
                Elf32_Ehdr * ehdr = (Elf32_Ehdr*)elf;
                Elf32_Phdr * phdr;

                int has = 0;

                for (Elf32_Half i = 0; i < ehdr->e_phnum; i++) {
                    phdr = (Elf32_Phdr*)(elf + ehdr->e_phoff + i * ehdr->e_phentsize);

                    if (phdr->p_type == PT_DYNAMIC) {
                        has = 1;
                        break;
                    }
                }

                if (has == 0) {
                    return 0;
                }

                const char * dynstr = NULL;

                Elf32_Dyn * dyn;

                for (size_t i = 0; i < 100; i++) {
                    dyn = (Elf32_Dyn*)(elf + phdr->p_offset + i * sizeof(Elf32_Dyn));

                    if (dyn->d_tag == DT_NULL) {
                        break;
                    }

                    if (dyn->d_tag == DT_STRTAB) {
                        dynstr = (const char *)elf + dyn->d_un.d_ptr;
                        break;
                    }
                }

                if (dynstr == NULL) {
                    return 1;
                }

                for (size_t i = 0; i < 100; i++) {
                    dyn = (Elf32_Dyn*)(elf + phdr->p_offset + i * sizeof(Elf32_Dyn));

                    if (dyn->d_tag == DT_NULL) {
                        break;
                    }

                    if (dyn->d_tag == DT_NEEDED) {
                        puts(dynstr + dyn->d_un.d_val);
                    }
                }
            }
            return 0;
        default: 
            fprintf(stderr, "Invalid ELF file: %s\n", argv[1]);
            return 101;
    }
}
