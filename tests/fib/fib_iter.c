// fib_iter.c

#pragma GCC push_options
#pragma GCC optimize ("O0") // this function cannot be optimized
void exitECALL(volatile int statusCode) { // statusCode is passed through register a0
    asm("li a7, 93"); // not necessary because only one ecall present
    asm("ecall");
}
#pragma GCC pop_options

int fib(int n) {
    int a = 0, b = 1, c, i;
    if (n == 0)
        return a;
    for (i = 2; i <= n; i++) {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main() {
    int res = fib(16);
    exitECALL(res);
    return 0;
}
