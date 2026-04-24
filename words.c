#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main(void)
{
    char   line[1024];
    int    words;
    int    chars;
    int    in_word;
    size_t i;
    size_t len;

    if (fgets(line, sizeof(line), stdin) == NULL) {
        printf("0 words, 0 characters\n");
        return (0);
    }
    words = 0;
    chars = 0;
    in_word = 0;
    len = strlen(line);
    i = 0;
    while (i < len) {
        if (line[i] == '\n')
            break;
        chars++;
        if (!isspace((unsigned char)line[i])) {
            if (!in_word) {
                words++;
                in_word = 1;
            }
        }
        else
            in_word = 0;
        i++;
    }
    printf("%d %s, %d %s\n", words, words == 1 ? "word" : "words",
        chars, chars == 1 ? "character" : "characters");
    return (0);
}
