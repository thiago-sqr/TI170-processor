#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <map>

#define WORD_SIZE 8
#define MIN_LINE 128

using namespace std;

struct info {
    string opcode;
    int arguments;
};

map<string, info> mnemonics = {
    { "INC", info{"00000001", 1} }, // incremento
    { "DEC", info{"00000010", 1} }, // decremento
    { "NOT", info{"00000011", 1} }, // negação
    { "JMP", info{"00000100", 1} }, // salto (avança instruções, ignorando intermediárias)
    { "ADD", info{"00010000", 2} }, // adição
    { "SUB", info{"00100000", 2} }, // subtração
    { "MUL", info{"00110000", 2} }, // multiplicação
    { "DIV", info{"01000000", 2} }, // divisão
    { "MOD", info{"01010000", 2} }, // resto da divisão
    { "AND", info{"01100000", 2} }, // AND
    { "OR" , info{"01110000", 2} }, // OR
    { "XOR", info{"10000000", 2} }, // XOR
    {"NAND", info{"10010000", 2} }, // NAND
    { "NOR", info{"10100000", 2} }, // NOR
    {"XNOR", info{"10110000", 2} }, // XNOR
    {"COMP", info{"11000000", 2} } // Comparação
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
    return mnemonics.count(s) == 1;
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
    int asmLineCounter = 0, writtenLineCounter = 0;

    // Loop principal: procura comandos que são representados por mnemonicos válidos
    while (getline(asm_file, cmdBuffer)) {
        
        asmLineCounter++;
        removeComments(cmdBuffer); removeSpaces(cmdBuffer);

        if (cmdBuffer.empty()) continue;

        if (!isCommand(cmdBuffer)) {
            cerr << "Semantic Error in line " << asmLineCounter << ": Command " << cmdBuffer << " is undefined" << endl;
            asm_file.close(); bin_file.close();
            return 3;
        }

        int expectedArgs = getArguments(cmdBuffer);
        string opcode = getOpcode(cmdBuffer);

        bin_file.write(opcode.c_str(), opcode.size());
        bin_file.put('\n');
        writtenLineCounter++;

        // Loop interno: analisa argumentos (linhas seguintes) para os comandos
        for (int i = 0; i < expectedArgs; i++) {
            
            asmLineCounter++;

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
                cerr << "Syntactic Error in line " << asmLineCounter << ": Invalid argument " << argBuffer << " for command " << cmdBuffer << endl;
                cerr << "Expected binary argument of size " << WORD_SIZE << endl;
                asm_file.close(); bin_file.close();
                return 5;
            }

            argBuffer = completeArgument(argBuffer);
            bin_file.write(argBuffer.c_str(), argBuffer.size());
            bin_file.put('\n');
            writtenLineCounter++;
        }
    }

    // Laço para completar o arquivo com o número mínimo de linhas
    for (int i = 0; i < MIN_LINE - writtenLineCounter; i++) {
        bin_file.write(completeArgument("0").c_str(), argBuffer.size());
        if (i == MIN_LINE - writtenLineCounter - 1) break;
        bin_file.put('\n');
    }

    asm_file.close(); bin_file.close();
    return 0;
}
