#include <unistd.h>

int main(void) {
    if (setgid(0) != 0 || setuid(0) != 0) {
        return 1;
    }
    execl("/bin/sh", "sh", "/opt/lunar/rotate.sh", (char *)0);
    return 1;
}
