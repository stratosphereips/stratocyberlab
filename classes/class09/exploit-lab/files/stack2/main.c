#include <stdio.h>
#include <string.h>

void success() {
	printf("Access granted!\n");
}

int main() {
	char buffer[64];

	gets(buffer);

	return 0;
}
