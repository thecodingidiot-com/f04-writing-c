#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(void)
{
    int target;
    int guess;
    int attempts;

    srand((unsigned int)time(NULL));
    target = rand() % 100 + 1;
    attempts = 0;
    printf("I'm thinking of a number between 1 and 100.\n");
    while (1)
    {
        printf("Your guess: ");
        if (scanf("%d", &guess) != 1)
            break;
        attempts++;
        if (guess < target)
            printf("Too low.\n");
        else if (guess > target)
            printf("Too high.\n");
        else
        {
            printf("Correct — %d attempt", attempts);
            if (attempts != 1)
                printf("s");
            printf(".\n");
            break;
        }
    }
    return (0);
}
