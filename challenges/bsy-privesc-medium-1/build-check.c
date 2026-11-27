#include <stdio.h>
#include <unistd.h>

int main(void) {
    char *const argv[] = {"build-helper", NULL};

    if (setuid(0) != 0) {
        perror("setuid");
        return 1;
    }

    execvp(argv[0], argv);
    perror("build-helper");
    return 1;
}
