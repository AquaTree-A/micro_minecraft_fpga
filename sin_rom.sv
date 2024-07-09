module sin_rom (
    input logic [8:0] angle, // Input angle from 0 to 359
    output int sin_value // Output sin value * 2^16
);

    always_comb begin
        case (angle)
            9'd0: sin_value = 0;
            9'd1: sin_value = 1143;
            9'd2: sin_value = 2287;
            9'd3: sin_value = 3429;
            9'd4: sin_value = 4571;
            9'd5: sin_value = 5711;
            9'd6: sin_value = 6850;
            9'd7: sin_value = 7986;
            9'd8: sin_value = 9120;
            9'd9: sin_value = 10252;
            9'd10: sin_value = 11380;
            9'd11: sin_value = 12504;
            9'd12: sin_value = 13625;
            9'd13: sin_value = 14742;
            9'd14: sin_value = 15854;
            9'd15: sin_value = 16961;
            9'd16: sin_value = 18064;
            9'd17: sin_value = 19160;
            9'd18: sin_value = 20251;
            9'd19: sin_value = 21336;
            9'd20: sin_value = 22414;
            9'd21: sin_value = 23486;
            9'd22: sin_value = 24550;
            9'd23: sin_value = 25606;
            9'd24: sin_value = 26655;
            9'd25: sin_value = 27696;
            9'd26: sin_value = 28729;
            9'd27: sin_value = 29752;
            9'd28: sin_value = 30767;
            9'd29: sin_value = 31772;
            9'd30: sin_value = 32767;
            9'd31: sin_value = 33753;
            9'd32: sin_value = 34728;
            9'd33: sin_value = 35693;
            9'd34: sin_value = 36647;
            9'd35: sin_value = 37589;
            9'd36: sin_value = 38521;
            9'd37: sin_value = 39440;
            9'd38: sin_value = 40347;
            9'd39: sin_value = 41243;
            9'd40: sin_value = 42125;
            9'd41: sin_value = 42995;
            9'd42: sin_value = 43852;
            9'd43: sin_value = 44695;
            9'd44: sin_value = 45525;
            9'd45: sin_value = 46340;
            9'd46: sin_value = 47142;
            9'd47: sin_value = 47929;
            9'd48: sin_value = 48702;
            9'd49: sin_value = 49460;
            9'd50: sin_value = 50203;
            9'd51: sin_value = 50931;
            9'd52: sin_value = 51643;
            9'd53: sin_value = 52339;
            9'd54: sin_value = 53019;
            9'd55: sin_value = 53683;
            9'd56: sin_value = 54331;
            9'd57: sin_value = 54963;
            9'd58: sin_value = 55577;
            9'd59: sin_value = 56175;
            9'd60: sin_value = 56755;
            9'd61: sin_value = 57319;
            9'd62: sin_value = 57864;
            9'd63: sin_value = 58393;
            9'd64: sin_value = 58903;
            9'd65: sin_value = 59395;
            9'd66: sin_value = 59870;
            9'd67: sin_value = 60326;
            9'd68: sin_value = 60763;
            9'd69: sin_value = 61183;
            9'd70: sin_value = 61583;
            9'd71: sin_value = 61965;
            9'd72: sin_value = 62328;
            9'd73: sin_value = 62672;
            9'd74: sin_value = 62997;
            9'd75: sin_value = 63302;
            9'd76: sin_value = 63589;
            9'd77: sin_value = 63856;
            9'd78: sin_value = 64103;
            9'd79: sin_value = 64331;
            9'd80: sin_value = 64540;
            9'd81: sin_value = 64729;
            9'd82: sin_value = 64898;
            9'd83: sin_value = 65047;
            9'd84: sin_value = 65176;
            9'd85: sin_value = 65286;
            9'd86: sin_value = 65376;
            9'd87: sin_value = 65446;
            9'd88: sin_value = 65496;
            9'd89: sin_value = 65526;
            9'd90: sin_value = 65536;
            9'd91: sin_value = 65526;
            9'd92: sin_value = 65496;
            9'd93: sin_value = 65446;
            9'd94: sin_value = 65376;
            9'd95: sin_value = 65286;
            9'd96: sin_value = 65176;
            9'd97: sin_value = 65047;
            9'd98: sin_value = 64898;
            9'd99: sin_value = 64729;
            9'd100: sin_value = 64540;
            9'd101: sin_value = 64331;
            9'd102: sin_value = 64103;
            9'd103: sin_value = 63856;
            9'd104: sin_value = 63589;
            9'd105: sin_value = 63302;
            9'd106: sin_value = 62997;
            9'd107: sin_value = 62672;
            9'd108: sin_value = 62328;
            9'd109: sin_value = 61965;
            9'd110: sin_value = 61583;
            9'd111: sin_value = 61183;
            9'd112: sin_value = 60763;
            9'd113: sin_value = 60326;
            9'd114: sin_value = 59870;
            9'd115: sin_value = 59395;
            9'd116: sin_value = 58903;
            9'd117: sin_value = 58393;
            9'd118: sin_value = 57864;
            9'd119: sin_value = 57319;
            9'd120: sin_value = 56755;
            9'd121: sin_value = 56175;
            9'd122: sin_value = 55577;
            9'd123: sin_value = 54963;
            9'd124: sin_value = 54331;
            9'd125: sin_value = 53683;
            9'd126: sin_value = 53019;
            9'd127: sin_value = 52339;
            9'd128: sin_value = 51643;
            9'd129: sin_value = 50931;
            9'd130: sin_value = 50203;
            9'd131: sin_value = 49460;
            9'd132: sin_value = 48702;
            9'd133: sin_value = 47929;
            9'd134: sin_value = 47142;
            9'd135: sin_value = 46340;
            9'd136: sin_value = 45525;
            9'd137: sin_value = 44695;
            9'd138: sin_value = 43852;
            9'd139: sin_value = 42995;
            9'd140: sin_value = 42125;
            9'd141: sin_value = 41243;
            9'd142: sin_value = 40347;
            9'd143: sin_value = 39440;
            9'd144: sin_value = 38521;
            9'd145: sin_value = 37589;
            9'd146: sin_value = 36647;
            9'd147: sin_value = 35693;
            9'd148: sin_value = 34728;
            9'd149: sin_value = 33753;
            9'd150: sin_value = 32767;
            9'd151: sin_value = 31772;
            9'd152: sin_value = 30767;
            9'd153: sin_value = 29752;
            9'd154: sin_value = 28729;
            9'd155: sin_value = 27696;
            9'd156: sin_value = 26655;
            9'd157: sin_value = 25606;
            9'd158: sin_value = 24550;
            9'd159: sin_value = 23486;
            9'd160: sin_value = 22414;
            9'd161: sin_value = 21336;
            9'd162: sin_value = 20251;
            9'd163: sin_value = 19160;
            9'd164: sin_value = 18064;
            9'd165: sin_value = 16961;
            9'd166: sin_value = 15854;
            9'd167: sin_value = 14742;
            9'd168: sin_value = 13625;
            9'd169: sin_value = 12504;
            9'd170: sin_value = 11380;
            9'd171: sin_value = 10252;
            9'd172: sin_value = 9120;
            9'd173: sin_value = 7986;
            9'd174: sin_value = 6850;
            9'd175: sin_value = 5711;
            9'd176: sin_value = 4571;
            9'd177: sin_value = 3429;
            9'd178: sin_value = 2287;
            9'd179: sin_value = 1143;
            9'd180: sin_value = 0;
            9'd181: sin_value = -1143;
            9'd182: sin_value = -2287;
            9'd183: sin_value = -3429;
            9'd184: sin_value = -4571;
            9'd185: sin_value = -5711;
            9'd186: sin_value = -6850;
            9'd187: sin_value = -7986;
            9'd188: sin_value = -9120;
            9'd189: sin_value = -10252;
            9'd190: sin_value = -11380;
            9'd191: sin_value = -12504;
            9'd192: sin_value = -13625;
            9'd193: sin_value = -14742;
            9'd194: sin_value = -15854;
            9'd195: sin_value = -16961;
            9'd196: sin_value = -18064;
            9'd197: sin_value = -19160;
            9'd198: sin_value = -20251;
            9'd199: sin_value = -21336;
            9'd200: sin_value = -22414;
            9'd201: sin_value = -23486;
            9'd202: sin_value = -24550;
            9'd203: sin_value = -25606;
            9'd204: sin_value = -26655;
            9'd205: sin_value = -27696;
            9'd206: sin_value = -28729;
            9'd207: sin_value = -29752;
            9'd208: sin_value = -30767;
            9'd209: sin_value = -31772;
            9'd210: sin_value = -32768;
            9'd211: sin_value = -33753;
            9'd212: sin_value = -34728;
            9'd213: sin_value = -35693;
            9'd214: sin_value = -36647;
            9'd215: sin_value = -37589;
            9'd216: sin_value = -38521;
            9'd217: sin_value = -39440;
            9'd218: sin_value = -40347;
            9'd219: sin_value = -41243;
            9'd220: sin_value = -42125;
            9'd221: sin_value = -42995;
            9'd222: sin_value = -43852;
            9'd223: sin_value = -44695;
            9'd224: sin_value = -45525;
            9'd225: sin_value = -46340;
            9'd226: sin_value = -47142;
            9'd227: sin_value = -47929;
            9'd228: sin_value = -48702;
            9'd229: sin_value = -49460;
            9'd230: sin_value = -50203;
            9'd231: sin_value = -50931;
            9'd232: sin_value = -51643;
            9'd233: sin_value = -52339;
            9'd234: sin_value = -53019;
            9'd235: sin_value = -53683;
            9'd236: sin_value = -54331;
            9'd237: sin_value = -54963;
            9'd238: sin_value = -55577;
            9'd239: sin_value = -56175;
            9'd240: sin_value = -56755;
            9'd241: sin_value = -57319;
            9'd242: sin_value = -57864;
            9'd243: sin_value = -58393;
            9'd244: sin_value = -58903;
            9'd245: sin_value = -59395;
            9'd246: sin_value = -59870;
            9'd247: sin_value = -60326;
            9'd248: sin_value = -60763;
            9'd249: sin_value = -61183;
            9'd250: sin_value = -61583;
            9'd251: sin_value = -61965;
            9'd252: sin_value = -62328;
            9'd253: sin_value = -62672;
            9'd254: sin_value = -62997;
            9'd255: sin_value = -63302;
            9'd256: sin_value = -63589;
            9'd257: sin_value = -63856;
            9'd258: sin_value = -64103;
            9'd259: sin_value = -64331;
            9'd260: sin_value = -64540;
            9'd261: sin_value = -64729;
            9'd262: sin_value = -64898;
            9'd263: sin_value = -65047;
            9'd264: sin_value = -65176;
            9'd265: sin_value = -65286;
            9'd266: sin_value = -65376;
            9'd267: sin_value = -65446;
            9'd268: sin_value = -65496;
            9'd269: sin_value = -65526;
            9'd270: sin_value = -65536;
            9'd271: sin_value = -65526;
            9'd272: sin_value = -65496;
            9'd273: sin_value = -65446;
            9'd274: sin_value = -65376;
            9'd275: sin_value = -65286;
            9'd276: sin_value = -65176;
            9'd277: sin_value = -65047;
            9'd278: sin_value = -64898;
            9'd279: sin_value = -64729;
            9'd280: sin_value = -64540;
            9'd281: sin_value = -64331;
            9'd282: sin_value = -64103;
            9'd283: sin_value = -63856;
            9'd284: sin_value = -63589;
            9'd285: sin_value = -63302;
            9'd286: sin_value = -62997;
            9'd287: sin_value = -62672;
            9'd288: sin_value = -62328;
            9'd289: sin_value = -61965;
            9'd290: sin_value = -61583;
            9'd291: sin_value = -61183;
            9'd292: sin_value = -60763;
            9'd293: sin_value = -60326;
            9'd294: sin_value = -59870;
            9'd295: sin_value = -59395;
            9'd296: sin_value = -58903;
            9'd297: sin_value = -58393;
            9'd298: sin_value = -57864;
            9'd299: sin_value = -57319;
            9'd300: sin_value = -56755;
            9'd301: sin_value = -56175;
            9'd302: sin_value = -55577;
            9'd303: sin_value = -54963;
            9'd304: sin_value = -54331;
            9'd305: sin_value = -53683;
            9'd306: sin_value = -53019;
            9'd307: sin_value = -52339;
            9'd308: sin_value = -51643;
            9'd309: sin_value = -50931;
            9'd310: sin_value = -50203;
            9'd311: sin_value = -49460;
            9'd312: sin_value = -48702;
            9'd313: sin_value = -47929;
            9'd314: sin_value = -47142;
            9'd315: sin_value = -46340;
            9'd316: sin_value = -45525;
            9'd317: sin_value = -44695;
            9'd318: sin_value = -43852;
            9'd319: sin_value = -42995;
            9'd320: sin_value = -42125;
            9'd321: sin_value = -41243;
            9'd322: sin_value = -40347;
            9'd323: sin_value = -39440;
            9'd324: sin_value = -38521;
            9'd325: sin_value = -37589;
            9'd326: sin_value = -36647;
            9'd327: sin_value = -35693;
            9'd328: sin_value = -34728;
            9'd329: sin_value = -33753;
            9'd330: sin_value = -32768;
            9'd331: sin_value = -31772;
            9'd332: sin_value = -30767;
            9'd333: sin_value = -29752;
            9'd334: sin_value = -28729;
            9'd335: sin_value = -27696;
            9'd336: sin_value = -26655;
            9'd337: sin_value = -25606;
            9'd338: sin_value = -24550;
            9'd339: sin_value = -23486;
            9'd340: sin_value = -22414;
            9'd341: sin_value = -21336;
            9'd342: sin_value = -20251;
            9'd343: sin_value = -19160;
            9'd344: sin_value = -18064;
            9'd345: sin_value = -16961;
            9'd346: sin_value = -15854;
            9'd347: sin_value = -14742;
            9'd348: sin_value = -13625;
            9'd349: sin_value = -12504;
            9'd350: sin_value = -11380;
            9'd351: sin_value = -10252;
            9'd352: sin_value = -9120;
            9'd353: sin_value = -7986;
            9'd354: sin_value = -6850;
            9'd355: sin_value = -5711;
            9'd356: sin_value = -4571;
            9'd357: sin_value = -3429;
            9'd358: sin_value = -2287;
            9'd359: sin_value = -1143;
            default: sin_value = 0;
        endcase
    end
endmodule
