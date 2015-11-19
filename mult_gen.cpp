#include <iostream>
#include <stdlib.h>
#include <vector>
#include <ostream>
#include <cmath>
#include <ios>
#include <iomanip>
#include <sstream>
#include <assert.h>

bool big_counters;

enum OpType
{
      OP_EMPTY
    , OP_AND
    , OP_COUNTER_2 = 2
    , OP_COUNTER_3
    , OP_COUNTER_4
    , OP_COUNTER_5
    , OP_COUNTER_6
    , OP_COUNTER_7
    , OP_PROP
};

inline bool isCounter(OpType op)
{
    return (op >= OP_COUNTER_2 && op <= OP_COUNTER_7);
}

class Dot
{
    public:
        OpType op;
        int left_index, right_index;

        Dot();
};

typedef std::vector<Dot> Dots;

Dot::Dot()
{
    op = OP_EMPTY;
    left_index = -1;
    right_index = -1;
}

std::ostream& operator<<(std::ostream& os, const Dot& dot)
{
    std::stringstream output;

    if(isCounter(dot.op)) {
        if(dot.left_index != -1) {
            output << dot.left_index << " ";
        }
    }

    switch(dot.op) {
        case OP_EMPTY: output << "Z"; break;
        case OP_AND: output << dot.left_index << " AND " << dot.right_index; break;
        case OP_PROP: output << "PROP"; break;
        case OP_COUNTER_2: output << "2:2"; break;
        case OP_COUNTER_3: output << "3:2"; break;
        case OP_COUNTER_4: output << "4:3"; break;
        case OP_COUNTER_5: output << "5:3"; break;
        case OP_COUNTER_6: output << "6:3"; break;
        case OP_COUNTER_7: output << "7:3"; break;
        default: break;
    }

    if(dot.op >= OP_COUNTER_2 && dot.op <= OP_COUNTER_7) {
        if(dot.right_index != -1) {
            output << " " << dot.right_index;
        }
    }

    std::ios::fmtflags orig_flags(os.flags());
    os << std::setw(7) << output.str();
    os.flags(orig_flags);

    return os;
}

int getNextTargetHeight(int height)
{
    if(! big_counters) {
        if(height <= 2) {
            return 1;
        }

        int cur_level = 2;
        while(((int) (cur_level * 1.5)) < height) {
            cur_level = (int) (cur_level * 1.5);
        }
        return cur_level;
    }
    return -1;
}

void printDots(Dots *dots, int n)
{
    for(int i = 0; i < n; i++) {
        std::cout << (i % 10) << ": [";
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            std::cout << dots[i][j] << "|";
        }
        std::cout << "]\n";
    }
}

unsigned int countDots(Dots& dot_row)
{
    for(unsigned int i = 0; i < dot_row.size(); i++) {
        if(dot_row[i].op == OP_EMPTY) {
            return i;
        }
    }

    return dot_row.size();
}

int findLastUncompressed(Dots& dot_row)
{
    for(int i = (int) dot_row.size() - 1; i >= 0; i--) {
        if(dot_row[i].op == OP_PROP || dot_row[i].op == OP_AND) {
            return i;
        }
    }

    return -1;
}

void createDots(Dots *cur_dots, int size)
{
    for(int i = 1; i <= 2 * size; i++) {
        int num_dots = size - abs(i - size);
        for(int j = 0; j < size; j++) {
            Dot temp;
            if(j < num_dots) {
                temp.op = OP_AND;
                if(i < size) {
                    temp.left_index = i - 1 - j;
                    temp.right_index = j;
                } else {
                    temp.left_index = size - 1 - j;
                    temp.right_index = j + size - num_dots;
                }
            } else {
                temp.op = OP_EMPTY;
            }
            cur_dots[i - 1].push_back(temp);
        }
    }
}

void countCounters(int *counter_count, int diff)
{
    int start;
    if(big_counters) {
        start = 7;
    } else {
        start = 3;
    }

    for(int i = 7; i >= 2; i--) {
        if(i > start) {
            counter_count[i] = 0;
        } else {
            int count = diff / (i - 1);
            diff = diff % (i - 1);
            counter_count[i] = count;
        }
    }

    // never use 0 or 1 input counters (do they even exist?)
    counter_count[0] = 0;
    counter_count[1] = 0;
}

int computeStage(Dots *dots, int n, int height)
{
    int target_height = getNextTargetHeight(height);
    for(int i = 0; i < n - 1; i++) {
        int num_dots = countDots(dots[i]);

        if(num_dots > target_height) {
            int diff = num_dots - target_height;
            int counter_count[8];
            countCounters(counter_count, diff);
            
            for(int j = 7; j >= 2; j--) {
                for(int k = 0; k < counter_count[j]; k++) {
                    int next_row_avail = countDots(dots[i + 1]);
                    int repl;

                    for(int l = 0; l < j; l++) {
                        repl = findLastUncompressed(dots[i]);
                        //assert(dots[i][repl].left_index == -1);
                        dots[i][repl].op = (OpType) j;   // clever indexing
                        dots[i][repl].left_index = -1;
                        dots[i][repl].right_index = next_row_avail;
                    }

                    Dot next_dot;
                    next_dot.op = (OpType) j;
                    next_dot.left_index = repl;
                    next_dot.right_index = -1;
                    if((unsigned int) next_row_avail == dots[i + 1].size()) {
                        dots[i + 1].insert(dots[i + 1].begin() + next_row_avail, next_dot);
                    } else {
                        dots[i + 1][next_row_avail] = next_dot;
                    }
                }
            }
        }

        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(dots[i][j].op == OP_AND) {
                dots[i][j].op = OP_PROP;
            }
        }
    }

    return target_height;
}

void coalesceCounters(Dots *dots, int n, int target_height)
{
    for(int i = 0; i < n; i++) {
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(isCounter(dots[i][j].op)) {
                if(dots[i][j].left_index == -1) {
                    int cur_counter = dots[i][j].right_index;
                    while(isCounter(dots[i][j + 1].op) && dots[i][j + 1].right_index == cur_counter) {
                        dots[i].erase(dots[i].begin() + j + 1);
                    }
                }
                dots[i][j].op = OP_PROP;
            } else if(dots[i][j].op == OP_EMPTY && ((int) dots[i].size()) > target_height) {
                dots[i].erase(dots[i].begin() + j);
                j--;
            }
        }
    }
}

int main(int argc, char *argv[])
{
    if(argc != 3) {
        std::cout << "Usage: " << argv[0] << " size big-counters[0|1]\n";
        return 1;
    }

    int size = atoi(argv[1]);
    big_counters = ((atoi(argv[2]) == 0) ? false : true);

    Dots *cur_dots = new Dots[2 * size];
    createDots(cur_dots, size);
    printDots(cur_dots, 2 * size);

    int cur_height = size;
    while(cur_height > 2) {
        std::cout << "##########\n";
        cur_height = computeStage(cur_dots, 2 * size, cur_height);
        printDots(cur_dots, size * 2);
        std::cout << std::endl;
        coalesceCounters(cur_dots, 2 * size, cur_height);
        printDots(cur_dots, size * 2);
        std::cout << "##########\n";
    }

    return 0;
}
