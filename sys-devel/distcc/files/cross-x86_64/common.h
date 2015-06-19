#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(const int argc, char *const argv[])
{
    // + space for extra argument and NULL terminator
    char **const list = malloc(sizeof(char*) * (argc + 2));
    // extract file name, /usr/bin/name is assumed
    list[0] = bin;
    // architecture must be forced due to some buggy build systems
    list[1] = "-m64";
    // copy all other options;
    for (int i = 1; i < argc; i++)
        list[i+1] = argv[i];
    // list must be NULL-terminated
    list[argc + 1] = NULL;
    // call actual compiler
    execv(bin, list);
    // we should be never here
    perror("Failed to execv()");
    return 1;
}
