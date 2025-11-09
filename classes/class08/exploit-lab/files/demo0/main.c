#include <stdio.h>
#include <stdlib.h>

int foo() {
	return 0;
}

int main() {
	int stackVar = 666;

	printf("Address of a local variable        : %p\n", &stackVar);
	printf("Address of a our 'foo' function    : %p\n", &foo);
	printf("Address of a libc 'system' function: %p\n", &system);

	return 0;
}
