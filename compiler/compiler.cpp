#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <map>

#define WORD_SIZE 8

using namespace std;

struct info {
    string opcode;
    int arguments;
};

map<string, info> mnemonics = {
    { "ADD", info{"00000001", 2} },
    { "SUB", info{"00000010", 2} },
    { "NOT", info{"11111111", 1} }
    // adicionar mais mnemonicos aqui...
};

void removeComments(string &s) {
    size_t pos = s.find(";");
    if (pos != string::npos) s.erase(pos);
}

void removeSpaces(string &s) {
    s.erase(remove(s.begin(), s.end(), ' '), s.end());
}

bool isBinary(const string& s) {
    return !s.empty() && s.find_first_not_of("01") == string::npos;
}

bool isCommand(const string& s) {
    return mnemonics.count(s) != 1;
}

int getArguments(const string& s) {
    return mnemonics[s].arguments;
}

string getOpcode(const string& s) {
    return mnemonics[s].opcode;
}

string completeArgument(const string& binary) {
    size_t missingZeros = WORD_SIZE - binary.size();
    string fullBinary = string(missingZeros, '0') + binary;
    return fullBinary;
}


int main(int argc, char** argv) {

    if (argc != 3) {
        cerr << "Usage: ./compiler file.asm file.bin" << endl;
        return 1;
    }
    
    ifstream asm_file(argv[1]);
    if (!asm_file.is_open()) 
    {
        cerr << "Cannot open " << argv[1] << endl;
        return 2;
    }

    ofstream bin_file(argv[2], ios::out | ios::binary);
    if (!bin_file.is_open()) {
        cerr << "Cannot open " << argv[2] << endl;
        asm_file.close();
        return 2;
    }

    string cmdBuffer, argBuffer;

    // Loop principal: procura comandos que são representados por mnemonicos válidos
    while (getline(asm_file, cmdBuffer)) {

        removeComments(cmdBuffer); removeSpaces(cmdBuffer);

        if (cmdBuffer.empty()) continue;

        if (isCommand(cmdBuffer)) {
            cerr << "Semantic Error: Command " << cmdBuffer << " is undefined" << endl;
            asm_file.close(); bin_file.close();
            return 3;
        }

        int expectedArgs = getArguments(cmdBuffer);
        string opcode = getOpcode(cmdBuffer);

        bin_file.write(opcode.c_str(), opcode.size());
        bin_file.put('\n');

        // Loop interno: analisa argumentos (linhas seguintes) para os comandos
        for (int i = 0; i < expectedArgs; i++) {
            
            if (!getline(asm_file, argBuffer)) {
                cerr << "EOF reached before expected arguments" << endl;
                asm_file.close(); bin_file.close();
                return 4;
            }

            removeComments(argBuffer); removeSpaces(argBuffer);

            if (argBuffer.empty()) {
                i--; continue;
            }

            if (!isBinary(argBuffer) || argBuffer.size() > WORD_SIZE) {
                cerr << "Syntactic Error: Invalid argument " << argBuffer << " for command " << cmdBuffer << endl;
                cerr << "Expected binary argument of size " << WORD_SIZE << endl;
                asm_file.close(); bin_file.close();
                return 5;
            }

            argBuffer = completeArgument(argBuffer);
            bin_file.write(argBuffer.c_str(), argBuffer.size());
            bin_file.put('\n');
        }
    }

    asm_file.close(); bin_file.close();
    return 0;
}
