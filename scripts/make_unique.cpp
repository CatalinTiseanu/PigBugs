// author: Catalin-Stefan Tiseanu
// script for computing keeping unique (project_name, file_name) pairs

#include <sstream>
#include <map>
#include <string>
#include <cstring>
#include <cstdio>
#include <iostream>

#include <unordered_map>

using namespace std;

map<string, int> mp;

int main() {
  char buf[1<<24];

  int nr_processed = 0;

  while(gets(buf)) {
	++nr_processed;
    int count = 0;
    for (int i = 0; i < strlen(buf); ++i) {
      if ((int)buf[i] == 7) count++;
      if (count == 2) {count = i; break;}
    }
	if (!count) {
	  cerr << "error !" << endl;
	  cerr << buf << endl;
	  break;
	}
    string s = string(buf, buf + count);
    if (!mp.count(s)) {
      mp[s] = 1;
      puts(buf);
    } else {
	  //cerr << "Duplicate key " << s << endl; 
	}

	mp[s]++;

	if (nr_processed % 10000 == 0)
	  cerr << nr_processed << " lines processed" << endl;
  }

  cerr << "Total size of the map = " << mp.size() << endl;

  return 0;
}
