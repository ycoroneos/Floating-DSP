#include <iostream>
#include <iomanip>
#include <stdint.h>
using namespace std;

int main()
{
	float f = 1.0;
	unsigned int i;
	int32_t b;
	uint32_t a;

	while(1){
		cin >> a;

		std::cout << "a: " << a <<std::endl;
		b = a;
		std::cout << "b: " << b <<std::endl;
		f = float(b);
		std::cout << "f: " << f <<std::endl;
		i = *(int*)&f;
		std::cout << "i: " << i <<std::endl;
		cout << i << endl;
	}

	return 0;
}
