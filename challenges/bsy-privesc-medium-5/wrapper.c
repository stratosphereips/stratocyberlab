#include <unistd.h>

int main(void) {
    char *const args[] = {"python3", "/opt/city-control/reconcile.py", NULL};
    setgid(0);
    setuid(0);
    execv("/usr/bin/python3", args);
    return 1;
}
