// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TileSphere{
    mapping(uint => uint[6]) neighbors;
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
        neighbors[2][1] = 2;
        neighbors[2][2] = 4;
        neighbors[2][3] = 5;
        neighbors[2][4] = 41;
        neighbors[2][5] = 40;

        neighbors[3][0] = 0;
        neighbors[3][1] = 2;
        neighbors[3][2] = 4;
        neighbors[3][3] = 5;
        neighbors[3][4] = 1;
        neighbors[3][5] = 0;

        neighbors[4][1] = 2;
        neighbors[4][1] = 2;
        neighbors[4][0] = 0;
        neighbors[4][2] = 4;
        neighbors[4][3] = 5;
        neighbors[4][4] = 4;
        neighbors[4][5] = 4;

        neighbors[5][0] = 0;
        neighbors[5][1] = 2;
        neighbors[5][2] = 4;
        neighbors[5][3] = 5;
        neighbors[5][4] = 1;
        neighbors[5][5] = 0;

        neighbors[6][0] = 0;
        neighbors[6][1] = 2;
        neighbors[6][2] = 4;
        neighbors[6][3] = 5;
        neighbors[6][4] = 4;
        neighbors[6][5] = 4;

        neighbors[7][0] = 0;
        neighbors[7][1] = 2;
        neighbors[7][2] = 4;
        neighbors[7][3] = 5;
        neighbors[7][4] = 1;
        neighbors[7][5] = 4;

        neighbors[8][0] = 0;
        neighbors[8][1] = 2;
        neighbors[8][2] = 4;
        neighbors[8][3] = 5;
        neighbors[8][4] = 4;
        neighbors[8][5] = 0;

        neighbors[9][0] = 0;
        neighbors[9][1] = 2;
        neighbors[9][2] = 4;
        neighbors[9][3] = 5;
        neighbors[9][4] = 1;
        neighbors[9][5] = 0;

        neighbors[10][0] = 0;
        neighbors[10][1] = 2;
        neighbors[10][2] = 4;
        neighbors[10][3] = 5;
        neighbors[10][4] = 4;
        neighbors[10][5] = 4;

        neighbors[11][0] = 0;
        neighbors[11][1] = 2;
        neighbors[11][2] = 4;
        neighbors[11][3] = 5;
        neighbors[11][4] = 1;
        neighbors[11][5] = 0;

        neighbors[12][0] = 0;
        neighbors[12][1] = 2;
        neighbors[12][2] = 4;
        neighbors[12][3] = 5;
        neighbors[12][4] = 4;
        neighbors[12][5] = 4;

        neighbors[13][0] = 0;
        neighbors[13][1] = 2;
        neighbors[13][2] = 4;
        neighbors[13][3] = 5;
        neighbors[13][4] = 1;
        neighbors[13][5] = 0;

        neighbors[14][0] = 0;
        neighbors[14][1] = 2;
        neighbors[14][2] = 4;
        neighbors[14][3] = 5;
        neighbors[14][4] = 41;
        neighbors[14][5] = 40;

        neighbors[15][0] = 0;
        neighbors[15][1] = 2;
        neighbors[15][2] = 4;
        neighbors[15][3] = 5;
        neighbors[15][4] = 4;
        neighbors[15][5] = 4;

        neighbors[16][0] = 0;
        neighbors[16][1] = 2;
        neighbors[16][2] = 4;
        neighbors[16][3] = 5;
        neighbors[16][4] = 1;
        neighbors[16][5] = 0;

        neighbors[17][0] = 0;
        neighbors[17][1] = 2;
        neighbors[17][2] = 4;
        neighbors[17][3] = 5;
        neighbors[17][4] = 4;
        neighbors[17][5] = 4;

        neighbors[18][0] = 0;
        neighbors[18][1] = 2;
        neighbors[18][2] = 4;
        neighbors[18][3] = 5;
        neighbors[18][4] = 1;
        neighbors[18][5] = 0;

        neighbors[19][0] = 0;
        neighbors[19][1] = 2;
        neighbors[19][2] = 4;
        neighbors[19][3] = 5;
        neighbors[19][4] = 4;
        neighbors[19][5] = 4;

        neighbors[20][0] = 0;
        neighbors[20][1] = 2;
        neighbors[20][2] = 4;
        neighbors[20][3] = 5;
        neighbors[20][4] = 1;
        neighbors[20][5] = 0;

        neighbors[21][0] = 0;
        neighbors[21][1] = 2;
        neighbors[21][2] = 4;
        neighbors[21][3] = 5;
        neighbors[21][4] = 4;
        neighbors[21][5] = 4;

        neighbors[22][0] = 0;
        neighbors[22][1] = 2;
        neighbors[22][2] = 4;
        neighbors[22][3] = 5;
        neighbors[22][4] = 1;
        neighbors[22][5] = 0;

        neighbors[23][0] = 0;
        neighbors[23][1] = 2;
        neighbors[23][2] = 4;
        neighbors[23][3] = 5;
        neighbors[23][4] = 4;
        neighbors[23][5] = 4;

        neighbors[24][0] = 0;
        neighbors[24][1] = 2;
        neighbors[24][2] = 4;
        neighbors[24][3] = 5;
        neighbors[24][4] = 1;
        neighbors[24][5] = 0;

        neighbors[25][0] = 0;
        neighbors[25][1] = 2;
        neighbors[25][2] = 4;
        neighbors[25][3] = 5;
        neighbors[25][4] = 4;
        neighbors[25][5] = 4;

        neighbors[26][0] = 0;
        neighbors[26][1] = 2;
        neighbors[26][2] = 4;
        neighbors[26][3] = 5;
        neighbors[26][4] = 1;
        neighbors[26][5] = 0;

        neighbors[27][0] = 0;
        neighbors[27][1] = 2;
        neighbors[27][2] = 4;
        neighbors[27][3] = 5;
        neighbors[27][4] = 4;
        neighbors[27][5] = 4;

        neighbors[28][0] = 0;
        neighbors[28][1] = 2;
        neighbors[28][2] = 4;
        neighbors[28][3] = 5;
        neighbors[28][4] = 41;
        neighbors[28][5] = 40;

        neighbors[29][0] = 0;
        neighbors[29][1] = 2;
        neighbors[29][2] = 4;
        neighbors[29][3] = 5;
        neighbors[29][4] = 41;
        neighbors[29][5] = 40;

        neighbors[30][0] = 0;
        neighbors[30][1] = 2;
        neighbors[30][2] = 4;
        neighbors[30][3] = 5;
        neighbors[30][4] = 41;
        neighbors[30][5] = 40;

        neighbors[31][0] = 0;
        neighbors[31][1] = 2;
        neighbors[31][2] = 4;
        neighbors[31][3] = 5;
        neighbors[31][4] = 41;
        neighbors[31][5] = 40;

        neighbors[32][0] = 0;
        neighbors[32][1] = 2;
        neighbors[32][2] = 4;
        neighbors[32][3] = 5;
        neighbors[32][4] = 41;
        neighbors[32][5] = 40;

        neighbors[33][0] = 0;
        neighbors[33][1] = 2;
        neighbors[33][2] = 4;
        neighbors[33][3] = 5;
        neighbors[33][4] = 41;
        neighbors[33][5] = 40;

        neighbors[34][0] = 0;
        neighbors[34][1] = 2;
        neighbors[34][2] = 4;
        neighbors[34][3] = 5;
        neighbors[34][4] = 41;
        neighbors[34][5] = 40;

        neighbors[35][0] = 0;
        neighbors[35][1] = 2;
        neighbors[35][2] = 4;
        neighbors[35][3] = 5;
        neighbors[35][4] = 41;
        neighbors[35][5] = 40;

        neighbors[36][0] = 0;
        neighbors[36][1] = 2;
        neighbors[36][2] = 4;
        neighbors[36][3] = 5;
        neighbors[36][4] = 41;
        neighbors[36][5] = 40;

        neighbors[37][0] = 0;
        neighbors[37][1] = 2;
        neighbors[37][2] = 4;
        neighbors[37][3] = 5;
        neighbors[37][4] = 41;
        neighbors[37][5] = 40;

        neighbors[38][0] = 0;
        neighbors[38][1] = 2;
        neighbors[38][2] = 4;
        neighbors[38][3] = 5;
        neighbors[38][4] = 41;
        neighbors[38][5] = 40;

        neighbors[39][0] = 0;
        neighbors[39][1] = 2;
        neighbors[39][2] = 4;
        neighbors[39][3] = 5;
        neighbors[39][4] = 41;
        neighbors[39][5] = 40;

        neighbors[40][0] = 0;
        neighbors[40][1] = 2;
        neighbors[40][2] = 4;
        neighbors[40][3] = 5;
        neighbors[40][4] = 41;
        neighbors[40][5] = 40;

        neighbors[41][0] = 0;
        neighbors[41][1] = 2;
        neighbors[41][2] = 4;
        neighbors[41][3] = 5;
        neighbors[41][4] = 41;
        neighbors[41][5] = 40;
    }
}