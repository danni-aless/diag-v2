#include "branchy.h"

#include "util.h"

void branchy(int n)
{
    volatile int a = 0, b = 0, c = 0, d = 0, e = 0, f = 0, i;
	for (i = 0; i < n; i++) {
		if (f%3 == 0)
            a++;
		else
            b++;
        if (a%3 == 0)
            c++;
        else
            d++;
        if(b%3==0 && d%2==0)
            e++;
        else
            f++;
	}
    //printf("a=%d, b=%d, c=%d, d=%d, e=%d, f=%d\n", a, b, c, d, e, f);
}