#include <sstream>
#include <map>
#include <string>
#include <cstring>
#include <cstdio>

using namespace std;

map<string, int> mp;

int main() {
  char buf[1<<10];

  while(gets(buf)) {
    int count = 0;
    for (int i = 0; i < strlen(buf); ++i) {
      if (buf[i] == ',') count++;
      if (count == 2){ count = i; break;}
    }
    string s = string(buf, buf + count);
    if (!mp.count(s)) {
      mp[s] = 1;
      puts(buf);
    }
  }

  return 0;
}
