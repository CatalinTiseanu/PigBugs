// author: Catalin-Stefan Tiseanu
// quick 'script' for parsing a database and making sure it contains unique files

#include <sstream>
#include <map>
#include <string>
#include <cstring>
#include <cstdio>
#include <iostream>

using namespace std;

int main() {
  char buf[1<<20];

  int nr_processed = 0;

  while(gets(buf)) {
	++nr_processed;
    int count = 0;
    for (int i = 0; i < strlen(buf); ++i) {
      if ((int)buf[i] == 7) buf[i] = '\t';
    }
    puts(buf);
  }

  return 0;
}
