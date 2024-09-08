#include "fib.h"

#include "util.h"

int main(int argc, char* argv[])
{
    int n = 24;
    setStats(1);
    int fib_recursive = fib(n);
    int fib_iterative = fib_iter(n);
    setStats(0);
    printf("fib(%d) = %d\n", n, fib_recursive);
    printf("fib_iter(%d) = %d\n", n, fib_iterative);
    return !(fib_recursive==fib_iterative);
}
