#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char **child_argv = calloc((size_t)argc + 1, sizeof(char *));
    if (child_argv == NULL) {
        perror("calloc");
        return 1;
    }
    child_argv[0] = "date";
    for (int i = 1; i < argc; ++i) {
        child_argv[i] = argv[i];
    }
    execvp("date", child_argv);
    perror("execvp");
    return errno == 0 ? 1 : 127;
}
