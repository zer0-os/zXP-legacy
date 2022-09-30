// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TileSphere{
    mapping(uint => uint[6]) public neighbors;
    constructor(){
        neighbors[0][0] = 1;
        neighbors[0][1] = 2;
        neighbors[0][2] = 3;
        neighbors[0][3] = 4;
        neighbors[0][4] = 13;
        neighbors[0][5] = 15;

        neighbors[1][0] = 0;
        neighbors[1][1] = 2;
        neighbors[1][2] = 4;
        neighbors[1][3] = 5;
        neighbors[1][4] = 41;
        neighbors[1][5] = 40;

        neighbors[2][0] = 0;
        neighbors[2][1] = 1;
        neighbors[2][2] = 3;
        neighbors[2][3] = 5;
        neighbors[2][4] = 6;
        neighbors[2][5] = 7;

        neighbors[3][0] = 0;
        neighbors[3][1] = 2;
        neighbors[3][2] = 7;
        neighbors[3][3] = 10;
        neighbors[3][4] = 13;
        neighbors[3][5] = 0;

        neighbors[4][1] = 0;
        neighbors[4][1] = 1;
        neighbors[4][0] = 15;
        neighbors[4][2] = 39;
        neighbors[4][3] = 40;
        neighbors[4][4] = 0;

        neighbors[5][0] = 2;
        neighbors[5][1] = 1;
        neighbors[5][2] = 6;
        neighbors[5][3] = 32;
        neighbors[5][4] = 41;
        neighbors[5][5] = 2;

        neighbors[6][0] = 2;
        neighbors[6][1] = 7;
        neighbors[6][2] = 5;
        neighbors[6][3] = 8;
        neighbors[6][4] = 32;
        neighbors[6][5] = 33;

        neighbors[7][0] = 2;
        neighbors[7][1] = 6;
        neighbors[7][2] = 3;
        neighbors[7][3] = 8;
        neighbors[7][4] = 9;
        neighbors[7][5] = 10;

        neighbors[8][0] = 7;
        neighbors[8][1] = 6;
        neighbors[8][2] = 9;
        neighbors[8][3] = 33;
        neighbors[8][4] = 34;
        neighbors[8][5] = 7;

        neighbors[9][0] = 7;
        neighbors[9][1] = 10;
        neighbors[9][2] = 8;
        neighbors[9][3] = 11;
        neighbors[9][4] = 34;
        neighbors[9][5] = 35;

        neighbors[10][0] = 7;
        neighbors[10][1] = 9;
        neighbors[10][2] = 3;
        neighbors[10][3] = 11;
        neighbors[10][4] = 12;
        neighbors[10][5] = 13;

        neighbors[11][0] = 10;
        neighbors[11][1] = 9;
        neighbors[11][2] = 12;
        neighbors[11][3] = 35;
        neighbors[11][4] = 36;
        neighbors[11][5] = 10;

        neighbors[12][0] = 10;
        neighbors[12][1] = 13;
        neighbors[12][2] = 11;
        neighbors[12][3] = 14;
        neighbors[12][4] = 36;
        neighbors[12][5] = 37;

        neighbors[13][0] = 10;
        neighbors[13][1] = 12;
        neighbors[13][2] = 3;
        neighbors[13][3] = 14;
        neighbors[13][4] = 15;
        neighbors[13][5] = 0;

        neighbors[14][0] = 13;
        neighbors[14][1] = 12;
        neighbors[14][2] = 15;
        neighbors[14][3] = 37;
        neighbors[14][4] = 38;
        neighbors[14][5] = 13;

        neighbors[15][0] = 13;
        neighbors[15][1] = 0;
        neighbors[15][2] = 14;
        neighbors[15][3] = 4;
        neighbors[15][4] = 38;
        neighbors[15][5] = 39;

        neighbors[16][0] = 17;
        neighbors[16][1] = 18;
        neighbors[16][2] = 19;
        neighbors[16][3] = 20;
        neighbors[16][4] = 29;
        neighbors[16][5] = 31;

        neighbors[17][0] = 16;
        neighbors[17][1] = 18;
        neighbors[17][2] = 20;
        neighbors[17][3] = 21;
        neighbors[17][4] = 41;
        neighbors[17][5] = 32;

        neighbors[18][0] = 16;
        neighbors[18][1] = 17;
        neighbors[18][2] = 19;
        neighbors[18][3] = 21;
        neighbors[18][4] = 22;
        neighbors[18][5] = 23;

        neighbors[19][0] = 16;
        neighbors[19][1] = 18;
        neighbors[19][2] = 23;
        neighbors[19][3] = 26;
        neighbors[19][4] = 29;
        neighbors[19][5] = 16;

        neighbors[20][0] = 16;
        neighbors[20][1] = 17;
        neighbors[20][2] = 31;
        neighbors[20][3] = 32;
        neighbors[20][4] = 33;
        neighbors[20][5] = 16;

        neighbors[21][0] = 18;
        neighbors[21][1] = 17;
        neighbors[21][2] = 22;
        neighbors[21][3] = 40;
        neighbors[21][4] = 41;
        neighbors[21][5] = 18;

        neighbors[22][0] = 18;
        neighbors[22][1] = 23;
        neighbors[22][2] = 21;
        neighbors[22][3] = 24;
        neighbors[22][4] = 39;
        neighbors[22][5] = 40;

        neighbors[23][0] = 18;
        neighbors[23][1] = 22;
        neighbors[23][2] = 19;
        neighbors[23][3] = 24;
        neighbors[23][4] = 25;
        neighbors[23][5] = 26;

        neighbors[24][0] = 23;
        neighbors[24][1] = 22;
        neighbors[24][2] = 25;
        neighbors[24][3] = 38;
        neighbors[24][4] = 39;
        neighbors[24][5] = 23;

        neighbors[25][0] = 23;
        neighbors[25][1] = 26;
        neighbors[25][2] = 24;
        neighbors[25][3] = 27;
        neighbors[25][4] = 37;
        neighbors[25][5] = 38;

        neighbors[26][0] = 23;
        neighbors[26][1] = 25;
        neighbors[26][2] = 19;
        neighbors[26][3] = 27;
        neighbors[26][4] = 28;
        neighbors[26][5] = 29;

        neighbors[27][0] = 26;
        neighbors[27][1] = 25;
        neighbors[27][2] = 28;
        neighbors[27][3] = 36;
        neighbors[27][4] = 37;
        neighbors[27][5] = 26;

        neighbors[28][0] = 26;
        neighbors[28][1] = 29;
        neighbors[28][2] = 27;
        neighbors[28][3] = 30;
        neighbors[28][4] = 35;
        neighbors[28][5] = 36;

        neighbors[29][0] = 26;
        neighbors[29][1] = 28;
        neighbors[29][2] = 19;
        neighbors[29][3] = 30;
        neighbors[29][4] = 31;
        neighbors[29][5] = 16;

        neighbors[30][0] = 29;
        neighbors[30][1] = 28;
        neighbors[30][2] = 31;
        neighbors[30][3] = 34;
        neighbors[30][4] = 35;
        neighbors[30][5] = 29;

        neighbors[31][0] = 29;
        neighbors[31][1] = 16;
        neighbors[31][2] = 30;
        neighbors[31][3] = 20;
        neighbors[31][4] = 33;
        neighbors[31][5] = 34;

        neighbors[32][0] = 33;
        neighbors[32][1] = 6;
        neighbors[32][2] = 5;
        neighbors[32][3] = 20;
        neighbors[32][4] = 41;
        neighbors[32][5] = 17;

        neighbors[33][0] = 32;
        neighbors[33][1] = 6;
        neighbors[33][2] = 20;
        neighbors[33][3] = 8;
        neighbors[33][4] = 31;
        neighbors[33][5] = 34;

        neighbors[34][0] = 33;
        neighbors[34][1] = 31;
        neighbors[34][2] = 8;
        neighbors[34][3] = 30;
        neighbors[34][4] = 35;
        neighbors[34][5] = 9;

        neighbors[35][0] = 34;
        neighbors[35][1] = 9;
        neighbors[35][2] = 30;
        neighbors[35][3] = 11;
        neighbors[35][4] = 28;
        neighbors[35][5] = 36;

        neighbors[36][0] = 35;
        neighbors[36][1] = 28;
        neighbors[36][2] = 11;
        neighbors[36][3] = 27;
        neighbors[36][4] = 37;
        neighbors[36][5] = 12;

        neighbors[37][0] = 36;
        neighbors[37][1] = 12;
        neighbors[37][2] = 27;
        neighbors[37][3] = 14;
        neighbors[37][4] = 25;
        neighbors[37][5] = 38;

        neighbors[38][0] = 37;
        neighbors[38][1] = 25;
        neighbors[38][2] = 14;
        neighbors[38][3] = 24;
        neighbors[38][4] = 39;
        neighbors[38][5] = 15;

        neighbors[39][0] = 38;
        neighbors[39][1] = 15;
        neighbors[39][2] = 24;
        neighbors[39][3] = 4;
        neighbors[39][4] = 22;
        neighbors[39][5] = 40;

        neighbors[40][0] = 39;
        neighbors[40][1] = 22;
        neighbors[40][2] = 4;
        neighbors[40][3] = 21;
        neighbors[40][4] = 41;
        neighbors[40][5] = 1;

        neighbors[41][0] = 1;
        neighbors[41][1] = 40;
        neighbors[41][2] = 21;
        neighbors[41][3] = 5;
        neighbors[41][4] = 17;
        neighbors[41][5] = 32;
    }
}