#include <stdio.h>
#include <string.h>

void success() {
	printf("Access granted!\n");
}

void failure() {
	printf("Access denied!\n");
}

int main() {
	volatile void (*fp)() = failure;

	char buffer[64];

	gets(buffer);

	fp();

	return 0;
}
