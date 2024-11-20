#include <stdio.h>
#include <string.h>

const char bsy[] = "!cyberlab_rocks!";
const char just_an_array[16] = { 0x4d, 0x7, 0x19, 0x54, 0x1c, 0x1c, 0x1f, 0x9, 0x15, 0x31, 0x1c, 0x47, 0xd, 0x7, 0x22, 0x4b };

int check_flag(char *flag){
  int str_len = strlen(flag);
  for (int i=0; i<str_len; i++){
    char temp = (just_an_array[i] - 5) ^ bsy[i];
    if (temp != flag[i]){
      return 0;
    }
  }
  return 1;
}

int main(int argc, char **argv){
  if (argc != 2){
    printf("Usage: %s flag\n", argv[0]);
  } else {
    char *flag = argv[1];
    if (strlen(flag) != 16){
      printf("Incorrect flag. Try harder!\n");
    } else {
      int result = check_flag(flag);
      if (result == 1){
        printf("You found it! You can submit the flag, good job :)\n");
      } else {
        printf("Nope, that's not it!\n");
      }
    }
  }
}
