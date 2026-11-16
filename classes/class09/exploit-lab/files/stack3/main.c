#include <stdio.h>
#include <string.h>

int main() {
	char buffer[64];

	gets(buffer);

	printf("%s\n", buffer);

	return 0;
}
