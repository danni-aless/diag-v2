#include "branchy.h"

#include "util.h"

int main(int argc, char* argv[])
{
    int n = 10000;
    setStats(1);
    branchy(n);
    setStats(0);
    return 0;
}
