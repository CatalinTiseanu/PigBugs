#include <iostream>
#include <sstream>

#include <string>
#include <algorithm>

const double threshold = 0.4;
const int nr_of_columns = 21;

using namespace std;

int main() {
  string line;
  string dummy1, dummy2;
  double val;

  cin >> line;

  while (cin >> line) {
    replace(line.begin(), line.end(), ',', ' ');
    cerr << line << endl;
    stringstream ss, oo;
    ss << line;

    char x;
    while (ss >> x) {

    }

    ss >> dummy1 >> dummy2;
    oo << dummy1 << "," << dummy2;
    for (int i = 0; i < nr_of_columns - 3; ++i) {
      cin >> val;
      oo << "," << val;
    }
    
    cin >> val;
    oo << (val < threshold ? "0" : "1");
  
    cout << oo.str() << endl;
  }

  return 0;
}
