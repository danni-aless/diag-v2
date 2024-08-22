// fib.c

#pragma GCC push_options
#pragma GCC optimize ("O0") // this function cannot be optimized
void exitECALL(volatile int statusCode) { // statusCode is passed through register a0
    asm("li a7, 93"); // not necessary because only one ecall present
    asm("ecall");
}
#pragma GCC pop_options

int fib(int n) {
    if(n == 0) return 0;
    if(n == 1) return 1;
    return fib(n-1) + fib(n-2);
}

int main() {
    int res = fib(16);
    exitECALL(res);
    return 0;
}
