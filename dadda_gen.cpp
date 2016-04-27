#include <iostream>
#include <stdlib.h>
#include <vector>
#include <ostream>
#include <cmath>
#include <ios>
#include <iomanip>
#include <sstream>
#include <fstream>

// Define all possible dot types.
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
    , OP_COUNTER_8
    , OP_COUNTER_9
    , OP_COUNTER_10
    , OP_COUNTER_11
    , OP_COUNTER_12
    , OP_COUNTER_13
    , OP_COUNTER_14
    , OP_COUNTER_15
    , OP_PROP
};

// Check if dot is being used as part of a counter.
inline bool isCounter(OpType op) { return (op >= OP_COUNTER_2 && op <= OP_COUNTER_15); }
inline bool isSmallCounter(OpType op) { return (op >= OP_COUNTER_2 && op <= OP_COUNTER_3); }
inline bool isBigCounter(OpType op) { return (op > OP_COUNTER_3 && op <= OP_COUNTER_7); }
inline bool isSuperBigCounter(OpType op) { return (op > OP_COUNTER_7 && op <= OP_COUNTER_15); }

class Dot
{
    public:
        OpType op;
        std::string name;
        std::string prev_name;
        int left_index, right_index;

        Dot();
        void assignName(std::string new_name);
};

typedef std::vector<Dot> Dots;

// Initialize dot to be empty.
Dot::Dot()
{
    op = OP_EMPTY;
    left_index = -1;
    right_index = -1;
    name = "NO NAME";
    prev_name = "NO NAME";
}

inline bool isCounter(OpType op);
std::ostream& operator<<(std::ostream& os, const Dot& dot);
int getNextTargetHeight(int height, bool big_counters, bool super_big_counters);
void printDots(Dots *dots, int n, std::ostream& file);
unsigned int countDots(Dots& dot_row);
int findLastUncompressed(Dots& dot_row);
void createDots(Dots *cur_dots, int size);
void countCounters(int *counter_count, int diff, bool big_counters, bool super_big_counters);
int computeStage(Dots *dots, int n, int height, bool big_counters, bool super_big_counters);
void coalesceCounters(Dots *dots, int n, int target_height);
void createMulitplier(int size, bool big_counters, bool super_big_counters, std::ostream& output);
void generateTheVerilogFooter(std::ostream& file);
void generateTheVerilogHeader(int size, bool big_counters, bool super_big_counters, std::ostream& file);
void generateTheVerilog(Dots *dots, int size, int stage_num, std::ostream& file);
void generateTheVerilogAdder(Dots* dots, int n, std::ostream& file);

int main(int argc, char *argv[])
{
    if(argc != 2) {
        std::cout << "Usage: " << argv[0] << " config\n";
        std::cout << "    Configuration file is structured as follows: \n"
                  << "      output file\n"
                  << "      number of configurations\n"
                  << "      size big_counters[0|1] super_big_counters[0|1]\n"
                  << "      ...\n"
                  << "      size big_counters[0|1] super_big_counters[0|1]\n";
        return 1;
    }

    std::ifstream config_file(argv[1]);

    std::string out_file_name;
    config_file >> out_file_name;
    std::ofstream out_file(out_file_name.c_str());

    int config_count;
    config_file >> config_count;
    for(int i = 0; i < config_count; i++) {
        int size, big_counters_i, super_big_counters_i;
        config_file >> size >> big_counters_i >> super_big_counters_i;
        bool big_counters = ((big_counters_i == 0) ? false : true);
        bool super_big_counters = ((super_big_counters_i == 0) ? false : true);
        createMulitplier(size, big_counters, super_big_counters, out_file);
        out_file << "\n\n";
    }

    return 0;
}

// Print human-readable operation of a dot.
std::ostream& operator<<(std::ostream& os, const Dot& dot)
{
    std::stringstream output;

    // If it is a counter, it keeps track of its source (stored in left_index).
    if(isCounter(dot.op)) {
        if(dot.left_index != -1) {
            output << dot.left_index << " ";
        }
    }

    switch(dot.op) {
        case OP_EMPTY: output << "Z"; break;
        case OP_AND: output << dot.left_index << " AND " << dot.right_index; break;
        case OP_PROP: output << "PROP"; break;
        case OP_COUNTER_2: output  << "2:2";  break;
        case OP_COUNTER_3: output  << "3:2";  break;
        case OP_COUNTER_4: output  << "4:3";  break;
        case OP_COUNTER_5: output  << "5:3";  break;
        case OP_COUNTER_6: output  << "6:3";  break;
        case OP_COUNTER_7: output  << "7:4";  break;
        case OP_COUNTER_8: output  << "8:4";  break;
        case OP_COUNTER_9: output  << "9:4";  break;
        case OP_COUNTER_10: output << "10:4"; break;
        case OP_COUNTER_11: output << "11:4"; break;
        case OP_COUNTER_12: output << "12:4"; break;
        case OP_COUNTER_13: output << "13:4"; break;
        case OP_COUNTER_14: output << "14:4"; break;
        case OP_COUNTER_15: output << "15:4"; break;
        default: break;
    }

    // If it is a counter, it keeps track of where the output (stored in right_index) goes.
    if(isCounter(dot.op)) {
        if(dot.right_index != -1) {
            output << " " << dot.right_index;
        }
    }

    // Print with padding for easy viewing.
    //std::ios::fmtflags orig_flags(os.flags());
    os << output.str();
    //os << std::setw(12) << output.str();
    //os.flags(orig_flags);

    return os;
}

// Given a height, computes what the Dadda height limit should be for the next iteration.
int getNextTargetHeight(int height, bool big_counters, bool super_big_counters)
{
    if(height <= 2) {
        return 1;
    }

    if(! big_counters) {
        return (int)(ceil(height * 2.0 / 3.0));
    } else {
        if(! super_big_counters) {
            if(height > 80) {
                return 80;
            } else if(height > 35) {
                return 35;
            } else if(height > 15) {
                return 15;
            } else if(height > 7) {
                return 7;
            } else if(height > 3) {
                return 3;
            } else if(height > 2) {
                return 2;
            }
        } else {
            if(height > 85) {
                return 85;
            } else if(height > 22) {
                return 22;
            } else if(height > 7) {
                return 7;
            } else if(height > 3) {
                return 3;
            } else if(height > 2) {
                return 2;
            }
        }
    }
    return -1;
}

// Prints the dot matrix in a dot diagram fashion (right to left instead of top to bottom, though).
void printDots(Dots *dots, int n, std::ostream& file)
{
    file << "    /*\n";
    for(int i = 0; i < n; i++) {
        file << "      " <<  (i % 10) << ": [";
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            file << dots[i][j] << "|";
        }
        file << "]\n";
    }
    file << "    */\n";
}

// Given a row, counts how many dots (used or unused) there are.
unsigned int countDots(Dots& dot_row)
{
    for(unsigned int i = 0; i < dot_row.size(); i++) {
        // As soon as we see an empty one we can return, because Zs will always be after dots.
        if(dot_row[i].op == OP_EMPTY) {
            return i;
        }
    }

    // If the entire row has dots, the number of dots is the size of the row.
    return dot_row.size();
}

// Given a row, finds the first index at which there is an unused dot.
int findLastUncompressed(Dots& dot_row)
{
    // Start from the end of the row, looking for a dot that is either propagating or a partial product.
    for(int i = (int) dot_row.size() - 1; i >= 0; i--) {
        if(dot_row[i].op == OP_PROP || dot_row[i].op == OP_AND) {
            return i;
        }
    }

    // Return -1 if no uncompressed dots are found.
    return -1;
}

// Creates the initial array of partial products.
void createDots(Dots *cur_dots, int size)
{
    for(int i = 1; i <= 2 * size; i++) {
        // Compute the number of dots needed for a row. Strange looking because of the indexing method.
        int num_dots = size - abs(i - size);
        for(int j = 0; j < size; j++) {
            Dot temp;
            if(j < num_dots) {
                // If we have not marked all the dots we need for this row, compute partial products.
                temp.op = OP_AND;
                // Initial indexing is tricky since we prematurely move dots leftward (upward),
                // but the actual indices are based purely on the partial products in a dot diagram.
                if(i < size) {
                    temp.left_index = i - 1 - j;
                    temp.right_index = j;
                } else {
                    temp.left_index = size - 1 - j;
                    temp.right_index = j + size - num_dots;
                }
            } else {
                // If we have marked all the dots we need for this row, mark as empty.
                temp.op = OP_EMPTY;
            }
            cur_dots[i - 1].push_back(temp);
        }
    }
}

void countCounters(int *counter_count, int diff, bool big_counters, bool super_big_counters)
{
    int start;
    if(big_counters) {
        if(super_big_counters) {
            start = 15;
        } else {
            start = 7;
        }
    } else {
        start = 3;
    }

    // Greedy algorithm to pick the largest counters we can to reach our height limit.
    for(int i = 15; i >= 2; i--) {
        if(i > start) {
            // If we do not want to use big counters, just skip over them.
            counter_count[i] = 0;
        } else {
            // Compute how many of a counter we can use.
            int count = diff / (i - 1);
            diff = diff % (i - 1);
            // Use indices in counter_count to indicate which type of counter (e.g. index 2 is 2:2 counter).
            counter_count[i] = count;
        }
    }

    // Never use 0 or 1 counters.
    counter_count[0] = 0;
    counter_count[1] = 0;
}

// Adds counters to each row to ensure the height limit will be reached.
// This marks the dots with enough information to generate the Verilog, but
// it does not prepared for computing the next stage.
int computeStage(Dots *dots, int n, int height, bool big_counters, bool super_big_counters)
{
    // Compute target height.
    int target_height = getNextTargetHeight(height, big_counters, super_big_counters);

    // Iterate through each row, adding counters as needed.
    for(int i = 0; i < n - 1; i++) {
        // Count the number of dots we have.
        int num_dots = countDots(dots[i]);

        if(num_dots > target_height) {
            // If the number of dots exceeds our target height, we need to add some counters.
            int diff = num_dots - target_height;
            int counter_count[16];
            // Compute how many, and which, counters we need.
            countCounters(counter_count, diff, big_counters, super_big_counters);

            // Replace extraneous dots with counters, starting from the largest counter first.
            for(int j = 15; j >= 2; j--) {
                // Perform the replace operation for as many counters of size j that we have.
                for(int k = 0; k < counter_count[j]; k++) {
                    // Find the location in the next row where we can add the output of the counter.
                    int next_row_avail = countDots(dots[i + 1]);
                    int repl;

                    // Turn j dots into the counter inputs.
                    for(int l = 0; l < j; l++) {
                        // Find and makr the last free dot in the current row so that we can feed it into the counter.
                        // The right_index contains the index in the next row where the output will go.
                        repl = findLastUncompressed(dots[i]);
                        dots[i][repl].op = (OpType) j;   // clever indexing
                        dots[i][repl].left_index = -1;
                        dots[i][repl].right_index = next_row_avail;
                    }

                    // Create a new dot in the next row.
                    // The left_index contains the index of the first input to the counter.
                    Dot next_dot;
                    next_dot.op = (OpType) j;
                    next_dot.left_index = repl;
                    next_dot.right_index = -1;

                    if(j > 3) {
                        int next_next_row_avail = countDots(dots[i + 2]);
                        next_dot.right_index = next_next_row_avail;

                        Dot next_next_dot;
                        next_next_dot.op = (OpType) j;
                        next_next_dot.left_index = next_row_avail;
                        next_next_dot.right_index = -1;

                        if(j > 7) {
                            int next_next_next_row_avail = countDots(dots[i + 3]);
                            next_next_dot.right_index = next_next_next_row_avail;

                            Dot next_next_next_dot;
                            next_next_next_dot.op = (OpType) j;
                            next_next_next_dot.left_index = next_next_row_avail;
                            next_next_next_dot.right_index = -1;

                            // If we have space before dots[i + 3].size(), it means there is at least one Z. We can replace the Z.
                            if((unsigned int) next_next_next_row_avail == dots[i + 3].size()) {
                                dots[i + 3].insert(dots[i + 3].begin() + next_next_next_row_avail, next_next_next_dot);
                            } else {
                                dots[i + 3][next_next_next_row_avail] = next_next_next_dot;
                            }
                        }

                        // If we have space before dots[i + 2].size(), it means there is at least one Z. We can replace the Z.
                        if((unsigned int) next_next_row_avail == dots[i + 2].size()) {
                            dots[i + 2].insert(dots[i + 2].begin() + next_next_row_avail, next_next_dot);
                        } else {
                            dots[i + 2][next_next_row_avail] = next_next_dot;
                        }
                    }

                    // If we have space before dots[i + 1].size(), it means there is at least one Z. We can replace the Z.
                    if((unsigned int) next_row_avail == dots[i + 1].size()) {
                        dots[i + 1].insert(dots[i + 1].begin() + next_row_avail, next_dot);
                    } else {
                        dots[i + 1][next_row_avail] = next_dot;
                    }
                }
            }
        }

        // Mark any remaining AND operations as propagates.
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(dots[i][j].op == OP_AND) {
                dots[i][j].op = OP_PROP;
                dots[i][j].left_index = -1;
                dots[i][j].right_index = -1;
            }
        }
    }

    return target_height;
}

// Prepare the dots to compute the next stage. In other words, coalesce the counter
// dots into a single dot and mark them as free.
void coalesceCounters(Dots *dots, int n, int target_height)
{
    // Iterate through all the rows and coalesce/free.
    for(int i = 0; i < n; i++) {
        // Iterate through all the dots in the row.
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(isCounter(dots[i][j].op)) {
                // If the dot is being used in a counter, we may need to coalesce.
                if(dots[i][j].left_index == -1) {
                    // If the left_index == -1, this is a source and should be coalesced.
                    int cur_counter = dots[i][j].right_index;
                    // Remove all successive inputs to the same counter, effectively reducing the inputs to a single dot.
                    while(j + 1 < dots[i].size() && isCounter(dots[i][j + 1].op) && dots[i][j + 1].right_index == cur_counter) {
                        dots[i].erase(dots[i].begin() + j + 1);
                    }
                }
                // Mark the dot as freed.
                dots[i][j].op = OP_PROP;
            } else if(dots[i][j].op == OP_EMPTY && ((int) dots[i].size()) > target_height) {
                // If there are extraneous Zs, we can just remove them as needed.
                dots[i].erase(dots[i].begin() + j);
                j--;
            }
        }
    }
}

void createMulitplier(int size, bool big_counters, bool super_big_counters, std::ostream& output)
{
    generateTheVerilogHeader(size, big_counters, super_big_counters, output);

    Dots *cur_dots = new Dots[2 * size];
    createDots(cur_dots, size);

    generateTheVerilog(cur_dots, size, 0, output);
    output << "\n";

    int cur_height = size;
    int stage_count = 1;
    while(cur_height > 2) {
        cur_height = computeStage(cur_dots, 2 * size, cur_height, big_counters, super_big_counters);
        generateTheVerilog(cur_dots, size, stage_count, output);
        coalesceCounters(cur_dots, 2 * size, cur_height);
        output << "\n";
        stage_count++;
    }

    generateTheVerilogAdder(cur_dots, 2 * size, output);
    output << "\n";
    generateTheVerilogFooter(output);

    delete[] cur_dots;
}

void generateTheVerilogHeader(int size, bool big_counters, bool super_big_counters, std::ostream& file)
{
    std::string counter_label = "3_2";

    if(big_counters) {
        counter_label = "7_3";
        if(super_big_counters) {
            counter_label = "15_4";
        }
    }


    file << "module dadda" << size << "x" << size << "_" << counter_label << "(" << "a, b, prod);\n\n";
    file << "    input  wire [" << (size - 1) << ":0] a, b;\n";
    file << "    output wire [" << (2 * size - 1) << ":0] prod;\n\n";
}

void generateTheVerilogFooter(std::ostream& file)
{
    file << "endmodule\n";
}

void generateTheVerilog(Dots *dots, int size, int stage_num, std::ostream& file)
{
    file << "    // Begin stage " << stage_num << ".\n";
    printDots(dots, 2 * size, file);
    file << "\n";

    file << "    // Output wires for AND and PROP.\n";
    for(int i = 0; i < 2 * size; i++) {
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(dots[i][j].op == OP_AND || dots[i][j].op == OP_PROP) {
                std::stringstream wire_name;
                wire_name << "stage" << stage_num << "_" << i << "_" << j;
                dots[i][j].assignName(wire_name.str());
                file << "    wire " << wire_name.str() << ";\n";
            }
        }
    }

    file << "\n";

    static int and_id = 0;

    for(int i = 0; i < 2 * size; i++) {
        for(unsigned int j = 0; j < dots[i].size(); j++) {
            if(dots[i][j].op != OP_EMPTY) {
                if(dots[i][j].op == OP_AND) {
                    file << "    and gate" << (and_id++) << "(" << "a[" << dots[i][j].left_index << "], b[" << dots[i][j].right_index << "], " << dots[i][j].name << ");\n";
                } else if(isCounter(dots[i][j].op)) {
                    if(dots[i][j].left_index == -1) {
                        // Determine wire size.
                        file << "    wire ";
                        int counter_size;
                        if(isSmallCounter(dots[i][j].op)) {
                            file << "[1:0]";
                            counter_size = 3;
                        } else {
                            if(isBigCounter(dots[i][j].op)) {
                                file << "[2:0]";
                                counter_size = 7;
                            } else {
                                file << "[3:0]";
                                counter_size = 15;
                            }
                        }

                        // Determine wire name.
                        std::stringstream wire_name;
                        wire_name << "counter" << stage_num << "_" << i << "_" << j;
                        file << " " << wire_name.str() << ";\n";

                        // Create counter module.
                        int num_inputs = 1;
                        file << "    counter" << counter_size << " c" << stage_num << "_" << i << "_" << j << "({" << dots[i][j].name << ", ";

                        std::stringstream wire_part_name;
                        std::stringstream next_wire_part_name;
                        std::stringstream next_next_wire_part_name;
                        std::stringstream next_next_next_wire_part_name;
                        wire_part_name << wire_name.str() << "[0]";
                        next_wire_part_name << wire_name.str() << "[1]";
                        next_next_wire_part_name << wire_name.str() << "[2]";
                        next_next_next_wire_part_name << wire_name.str() << "[3]";
                        dots[i][j].assignName(wire_part_name.str());

                        int cur_counter = dots[i][j].right_index;
                        while(j + 1 < dots[i].size() && isCounter(dots[i][j + 1].op) && dots[i][j + 1].right_index == cur_counter) {
                            j++;
                            file << dots[i][j].name;
                            if(j + 1 < dots[i].size() && isCounter(dots[i][j + 1].op) && dots[i][j + 1].right_index == cur_counter) {
                                file << ", ";
                            }
                            num_inputs++;
                        }
                        for(int k = 0; k < counter_size - num_inputs; k++) {
                            if(k == 0) { file << ", "; }
                            file << "1'b0";
                            if(k + 1 < counter_size - num_inputs) { file << ", "; }
                        }
                        file << "}, " << wire_name.str() << ");\n";

                        dots[i + 1][dots[i][j].right_index].assignName(next_wire_part_name.str());
                        if(! isSmallCounter(dots[i][j].op)) {
                            dots[i + 2][dots[i + 1][dots[i][j].right_index].right_index].assignName(next_next_wire_part_name.str());
                            if(! isBigCounter(dots[i][j].op)) {
                                dots[i + 3][dots[i + 2][dots[i + 1][dots[i][j].right_index].right_index].right_index].assignName(next_next_next_wire_part_name.str());
                            }
                        }
                    }
                } else if(dots[i][j].op == OP_PROP) {
                    file << "    assign " << dots[i][j].name << " = " << dots[i][j].prev_name << ";\n";
                }
            }
        }
    }

    file << "    // End stage " << stage_num << ".\n";
}

void generateTheVerilogAdder(Dots* dots, int n, std::ostream& file)
{
    int adder_lsb = 0;
    while(dots[adder_lsb][1].op != OP_PROP) {
        adder_lsb++;
    }

    if(adder_lsb == 1) {
        file << "    assign prod[0] = " << dots[0][0].name << ";\n";
    } else {
        file << "    assign prod[" << (adder_lsb - 1) << ":0] = {";
        for(int i = 0; i < adder_lsb; i++) {
            file << dots[i][0].name;
            if(i + 1 < adder_lsb) {
                file << ", ";
            }
        }
        file << "};\n";
    }

    file << "    assign prod[" << (n - 1) << ":" << adder_lsb << "] = {";
    for(int i = n - 1; i >= adder_lsb; i--) {
        if(dots[i][0].op == OP_EMPTY) {
            file << "1\'b0";
        } else {
            file << dots[i][0].name;
        }
        if(i - 1 >= adder_lsb) {
            file << ", ";
        }
    }
    file << "} + \n                         {";

    for(int i = n - 1; i >= adder_lsb; i--) {
        if(dots[i][1].op == OP_EMPTY) {
            file << "1\'b0";
        } else {
            file << dots[i][1].name;
        }
        if(i - 1 >= adder_lsb) {
            file << ", ";
        }
    }
    file << "};\n";
}

void Dot::assignName(std::string new_name)
{
    prev_name = name;
    name = new_name;
}
