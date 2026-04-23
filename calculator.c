#include <stdio.h>

int add(int a, int b)
{
    return (a + b);
}

int subtract(int a, int b)
{
    return (a - b);
}

int multiply(int a, int b)
{
    return (a * b);
}

int divide(int a, int b)
{
    if (b == 0)
    {
        printf("Error: division by zero\n");
        return (0);
    }
    return (a / b);
}

int main(void)
{
    int  a;
    int  b;
    char op;

    printf("Enter: number operator number (e.g. 3 + 4)\n");
    scanf("%d %c %d", &a, &op, &b);
    if (op == '+')
        printf("%d %c %d = %d\n", a, op, b, add(a, b));
    else if (op == '-')
        printf("%d %c %d = %d\n", a, op, b, subtract(a, b));
    else if (op == '*')
        printf("%d %c %d = %d\n", a, op, b, multiply(a, b));
    else if (op == '/')
        printf("%d %c %d = %d\n", a, op, b, divide(a, b));
    else
        printf("Error: unknown operator '%c'\n", op);
    return (0);
}
