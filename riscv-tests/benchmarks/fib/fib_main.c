#include "fib.h"

#include "util.h"

int main(int argc, char* argv[])
{
    int n = 16;
    setStats(1);
    int fib_recursive = fib(n);
    printf("fib(%d) = %d\n", n, fib_recursive);
    int fib_iterative = fib_iter(n);
    printf("fib_iter(%d) = %d\n", n, fib_iterative);
    setStats(0);
    return !(fib_recursive==fib_iterative);
}
