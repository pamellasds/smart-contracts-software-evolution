pragma solidity ^0.4.24;
import ;
import ;

contract bancorformula is ibancorformula, utils {
    string public version = ;

    uint256 private constant one = 1;
    uint32 private constant max_weight = 1000000;
    uint8 private constant min_precision = 32;
    uint8 private constant max_precision = 127;

    
    uint256 private constant fixed_1 = 0x080000000000000000000000000000000;
    uint256 private constant fixed_2 = 0x100000000000000000000000000000000;
    uint256 private constant max_num = 0x200000000000000000000000000000000;

    
    uint256 private constant ln2_numerator   = 0x3f80fe03f80fe03f80fe03f80fe03f8;
    uint256 private constant ln2_denominator = 0x5b9de1d10bf4103d647b0955897ba80;

    
    uint256 private constant opt_log_max_val = 0x15bf0a8b1457695355fb8ac404e7a79e3;
    uint256 private constant opt_exp_max_val = 0x800000000000000000000000000000000;

    
    uint256[128] private maxexparray;
    constructor() public {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        maxexparray[ 32] = 0x1c35fedd14ffffffffffffffffffffffff;
        maxexparray[ 33] = 0x1b0ce43b323fffffffffffffffffffffff;
        maxexparray[ 34] = 0x19f0028ec1ffffffffffffffffffffffff;
        maxexparray[ 35] = 0x18ded91f0e7fffffffffffffffffffffff;
        maxexparray[ 36] = 0x17d8ec7f0417ffffffffffffffffffffff;
        maxexparray[ 37] = 0x16ddc6556cdbffffffffffffffffffffff;
        maxexparray[ 38] = 0x15ecf52776a1ffffffffffffffffffffff;
        maxexparray[ 39] = 0x15060c256cb2ffffffffffffffffffffff;
        maxexparray[ 40] = 0x1428a2f98d72ffffffffffffffffffffff;
        maxexparray[ 41] = 0x13545598e5c23fffffffffffffffffffff;
        maxexparray[ 42] = 0x1288c4161ce1dfffffffffffffffffffff;
        maxexparray[ 43] = 0x11c592761c666fffffffffffffffffffff;
        maxexparray[ 44] = 0x110a688680a757ffffffffffffffffffff;
        maxexparray[ 45] = 0x1056f1b5bedf77ffffffffffffffffffff;
        maxexparray[ 46] = 0x0faadceceeff8bffffffffffffffffffff;
        maxexparray[ 47] = 0x0f05dc6b27edadffffffffffffffffffff;
        maxexparray[ 48] = 0x0e67a5a25da4107fffffffffffffffffff;
        maxexparray[ 49] = 0x0dcff115b14eedffffffffffffffffffff;
        maxexparray[ 50] = 0x0d3e7a392431239fffffffffffffffffff;
        maxexparray[ 51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
        maxexparray[ 52] = 0x0c2d415c3db974afffffffffffffffffff;
        maxexparray[ 53] = 0x0bad03e7d883f69bffffffffffffffffff;
        maxexparray[ 54] = 0x0b320d03b2c343d5ffffffffffffffffff;
        maxexparray[ 55] = 0x0abc25204e02828dffffffffffffffffff;
        maxexparray[ 56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
        maxexparray[ 57] = 0x09deaf736ac1f569ffffffffffffffffff;
        maxexparray[ 58] = 0x0976bd9952c7aa957fffffffffffffffff;
        maxexparray[ 59] = 0x09131271922eaa606fffffffffffffffff;
        maxexparray[ 60] = 0x08b380f3558668c46fffffffffffffffff;
        maxexparray[ 61] = 0x0857ddf0117efa215bffffffffffffffff;
        maxexparray[ 62] = 0x07ffffffffffffffffffffffffffffffff;
        maxexparray[ 63] = 0x07abbf6f6abb9d087fffffffffffffffff;
        maxexparray[ 64] = 0x075af62cbac95f7dfa7fffffffffffffff;
        maxexparray[ 65] = 0x070d7fb7452e187ac13fffffffffffffff;
        maxexparray[ 66] = 0x06c3390ecc8af379295fffffffffffffff;
        maxexparray[ 67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
        maxexparray[ 68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
        maxexparray[ 69] = 0x05f63b1fc104dbd39587ffffffffffffff;
        maxexparray[ 70] = 0x05b771955b36e12f7235ffffffffffffff;
        maxexparray[ 71] = 0x057b3d49dda84556d6f6ffffffffffffff;
        maxexparray[ 72] = 0x054183095b2c8ececf30ffffffffffffff;
        maxexparray[ 73] = 0x050a28be635ca2b888f77fffffffffffff;
        maxexparray[ 74] = 0x04d5156639708c9db33c3fffffffffffff;
        maxexparray[ 75] = 0x04a23105873875bd52dfdfffffffffffff;
        maxexparray[ 76] = 0x0471649d87199aa990756fffffffffffff;
        maxexparray[ 77] = 0x04429a21a029d4c1457cfbffffffffffff;
        maxexparray[ 78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
        maxexparray[ 79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
        maxexparray[ 80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
        maxexparray[ 81] = 0x0399e96897690418f785257fffffffffff;
        maxexparray[ 82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
        maxexparray[ 83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
        maxexparray[ 84] = 0x032cbfd4a7adc790560b3337ffffffffff;
        maxexparray[ 85] = 0x030b50570f6e5d2acca94613ffffffffff;
        maxexparray[ 86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
        maxexparray[ 87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
        maxexparray[ 88] = 0x02af09481380a0a35cf1ba02ffffffffff;
        maxexparray[ 89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
        maxexparray[ 90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
        maxexparray[ 91] = 0x025daf6654b1eaa55fd64df5efffffffff;
        maxexparray[ 92] = 0x0244c49c648baa98192dce88b7ffffffff;
        maxexparray[ 93] = 0x022ce03cd5619a311b2471268bffffffff;
        maxexparray[ 94] = 0x0215f77c045fbe885654a44a0fffffffff;
        maxexparray[ 95] = 0x01ffffffffffffffffffffffffffffffff;
        maxexparray[ 96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
        maxexparray[ 97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
        maxexparray[ 98] = 0x01c35fedd14b861eb0443f7f133fffffff;
        maxexparray[ 99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
        maxexparray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
        maxexparray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
        maxexparray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
        maxexparray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
        maxexparray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
        maxexparray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
        maxexparray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
        maxexparray[107] = 0x013545598e5c23276ccf0ede68034fffff;
        maxexparray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
        maxexparray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
        maxexparray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
        maxexparray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
        maxexparray[112] = 0x00faadceceeff8a0890f3875f008277fff;
        maxexparray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
        maxexparray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
        maxexparray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
        maxexparray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
        maxexparray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
        maxexparray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
        maxexparray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
        maxexparray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
        maxexparray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
        maxexparray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
        maxexparray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
        maxexparray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
        maxexparray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
        maxexparray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
        maxexparray[127] = 0x00857ddf0117efa215952912839f6473e6;
    }

    
    function calculatepurchasereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _depositamount) public view returns (uint256) {
        
        require(_supply > 0 && _connectorbalance > 0 && _connectorweight > 0 && _connectorweight <= max_weight);

        
        if (_depositamount == 0)
            return 0;

        
        if (_connectorweight == max_weight)
            return safemul(_supply, _depositamount) / _connectorbalance;

        uint256 result;
        uint8 precision;
        uint256 basen = safeadd(_depositamount, _connectorbalance);
        (result, precision) = power(basen, _connectorbalance, _connectorweight, max_weight);
        uint256 temp = safemul(_supply, result) >> precision;
        return temp  _supply;
    }

    
    function calculatesalereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _sellamount) public view returns (uint256) {
        
        require(_supply > 0 && _connectorbalance > 0 && _connectorweight > 0 && _connectorweight <= max_weight && _sellamount <= _supply);

        
        if (_sellamount == 0)
            return 0;

        
        if (_sellamount == _supply)
            return _connectorbalance;

        
        if (_connectorweight == max_weight)
            return safemul(_connectorbalance, _sellamount) / _supply;

        uint256 result;
        uint8 precision;
        uint256 based = _supply  _sellamount;
        (result, precision) = power(_supply, based, max_weight, _connectorweight);
        uint256 temp1 = safemul(_connectorbalance, result);
        uint256 temp2 = _connectorbalance << precision;
        return (temp1  temp2) / result;
    }

    
    function calculatecrossconnectorreturn(uint256 _fromconnectorbalance, uint32 _fromconnectorweight, uint256 _toconnectorbalance, uint32 _toconnectorweight, uint256 _amount) public view returns (uint256) {
        
        require(_fromconnectorbalance > 0 && _fromconnectorweight > 0 && _fromconnectorweight <= max_weight && _toconnectorbalance > 0 && _toconnectorweight > 0 && _toconnectorweight <= max_weight);

        
        if (_fromconnectorweight == _toconnectorweight)
            return safemul(_toconnectorbalance, _amount) / safeadd(_fromconnectorbalance, _amount);

        uint256 result;
        uint8 precision;
        uint256 basen = safeadd(_fromconnectorbalance, _amount);
        (result, precision) = power(basen, _fromconnectorbalance, _fromconnectorweight, _toconnectorweight);
        uint256 temp1 = safemul(_toconnectorbalance, result);
        uint256 temp2 = _toconnectorbalance << precision;
        return (temp1  temp2) / result;
    }

    
    function power(uint256 _basen, uint256 _based, uint32 _expn, uint32 _expd) internal view returns (uint256, uint8) {
        require(_basen < max_num);

        uint256 baselog;
        uint256 base = _basen * fixed_1 / _based;
        if (base < opt_log_max_val) {
            baselog = optimallog(base);
        }
        else {
            baselog = generallog(base);
        }

        uint256 baselogtimesexp = baselog * _expn / _expd;
        if (baselogtimesexp < opt_exp_max_val) {
            return (optimalexp(baselogtimesexp), max_precision);
        }
        else {
            uint8 precision = findpositioninmaxexparray(baselogtimesexp);
            return (generalexp(baselogtimesexp >> (max_precision  precision), precision), precision);
        }
    }

    
    function generallog(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;

        
        if (x >= fixed_2) {
            uint8 count = floorlog2(x / fixed_1);
            x >>= count; 
            res = count * fixed_1;
        }

        
        if (x > fixed_1) {
            for (uint8 i = max_precision; i > 0; i) {
                x = (x * x) / fixed_1; 
                if (x >= fixed_2) {
                    x >>= 1; 
                    res += one << (i  1);
                }
            }
        }

        return res * ln2_numerator / ln2_denominator;
    }

    
    function floorlog2(uint256 _n) internal pure returns (uint8) {
        uint8 res = 0;

        if (_n < 256) {
            
            while (_n > 1) {
                _n >>= 1;
                res += 1;
            }
        }
        else {
            
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (_n >= (one << s)) {
                    _n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }

    
    function findpositioninmaxexparray(uint256 _x) internal view returns (uint8) {
        uint8 lo = min_precision;
        uint8 hi = max_precision;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (maxexparray[mid] >= _x)
                lo = mid;
            else
                hi = mid;
        }

        if (maxexparray[hi] >= _x)
            return hi;
        if (maxexparray[lo] >= _x)
            return lo;

        require(false);
        return 0;
    }

    
    function generalexp(uint256 _x, uint8 _precision) internal pure returns (uint256) {
        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision; res += xi * 0x3442c4e6074a82f1797f72ac0000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x116b96f757c380fb287fd0e40000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x045ae5bdd5f0e03eca1ff4390000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00defabf91302cd95b9ffda50000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x002529ca9832b22439efff9b8000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00054f1cf12bd04e516b6da88000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000a9e39e257a09ca2d6db51000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000012e066e7b839fa050c309000000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000001e33d7d926c329a1ad1a800000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000002bee513bdb4a6b19b5f800000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000003a9316fa79b88eccf2a00000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000048177ebe1fa812375200000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000005263fe90242dcbacf00000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000000000057e22099c030d94100000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000057e22099c030d9410000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000052b6b54569976310000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000004985f67696bf748000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000003dea12ea99e498000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000031880f2214b6e000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000025bcff56eb36000; 
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000001b722e10ab1000; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000001317c70077000; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000cba84aafa00; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000082573a0a00; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000005035ad900; 
        xi = (xi * _x) >> _precision; res += xi * 0x000000000000000000000002f881b00; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000001b29340; 
        xi = (xi * _x) >> _precision; res += xi * 0x00000000000000000000000000efc40; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000007fe0; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000420; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000021; 
        xi = (xi * _x) >> _precision; res += xi * 0x0000000000000000000000000000001; 

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (one << _precision); 
    }

    
    function optimallog(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;
        uint256 w;

        if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd8) {res += 0x40000000000000000000000000000000; x = x * fixed_1 / 0xd3094c70f034de4b96ff7d5b6f99fcd8;} 
        if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a7) {res += 0x20000000000000000000000000000000; x = x * fixed_1 / 0xa45af1e1f40c333b3de1db4dd55f29a7;} 
        if (x >= 0x910b022db7ae67ce76b441c27035c6a1) {res += 0x10000000000000000000000000000000; x = x * fixed_1 / 0x910b022db7ae67ce76b441c27035c6a1;} 
        if (x >= 0x88415abbe9a76bead8d00cf112e4d4a8) {res += 0x08000000000000000000000000000000; x = x * fixed_1 / 0x88415abbe9a76bead8d00cf112e4d4a8;} 
        if (x >= 0x84102b00893f64c705e841d5d4064bd3) {res += 0x04000000000000000000000000000000; x = x * fixed_1 / 0x84102b00893f64c705e841d5d4064bd3;} 
        if (x >= 0x8204055aaef1c8bd5c3259f4822735a2) {res += 0x02000000000000000000000000000000; x = x * fixed_1 / 0x8204055aaef1c8bd5c3259f4822735a2;} 
        if (x >= 0x810100ab00222d861931c15e39b44e99) {res += 0x01000000000000000000000000000000; x = x * fixed_1 / 0x810100ab00222d861931c15e39b44e99;} 
        if (x >= 0x808040155aabbbe9451521693554f733) {res += 0x00800000000000000000000000000000; x = x * fixed_1 / 0x808040155aabbbe9451521693554f733;} 

        z = y = x  fixed_1;
        w = y * y / fixed_1;
        res += z * (0x100000000000000000000000000000000  y) / 0x100000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  y) / 0x200000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x099999999999999999999999999999999  y) / 0x300000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x092492492492492492492492492492492  y) / 0x400000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x08e38e38e38e38e38e38e38e38e38e38e  y) / 0x500000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b  y) / 0x600000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x089d89d89d89d89d89d89d89d89d89d89  y) / 0x700000000000000000000000000000000; z = z * w / fixed_1; 
        res += z * (0x088888888888888888888888888888888  y) / 0x800000000000000000000000000000000;                      

        return res;
    }

    
    function optimalexp(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 y;
        uint256 z;

        z = y = x % 0x10000000000000000000000000000000; 
        z = z * y / fixed_1; res += z * 0x10e1b3be415a0000; 
        z = z * y / fixed_1; res += z * 0x05a0913f6b1e0000; 
        z = z * y / fixed_1; res += z * 0x0168244fdac78000; 
        z = z * y / fixed_1; res += z * 0x004807432bc18000; 
        z = z * y / fixed_1; res += z * 0x000c0135dca04000; 
        z = z * y / fixed_1; res += z * 0x0001b707b1cdc000; 
        z = z * y / fixed_1; res += z * 0x000036e0f639b800; 
        z = z * y / fixed_1; res += z * 0x00000618fee9f800; 
        z = z * y / fixed_1; res += z * 0x0000009c197dcc00; 
        z = z * y / fixed_1; res += z * 0x0000000e30dce400; 
        z = z * y / fixed_1; res += z * 0x000000012ebd1300; 
        z = z * y / fixed_1; res += z * 0x0000000017499f00; 
        z = z * y / fixed_1; res += z * 0x0000000001a9d480; 
        z = z * y / fixed_1; res += z * 0x00000000001c6380; 
        z = z * y / fixed_1; res += z * 0x000000000001c638; 
        z = z * y / fixed_1; res += z * 0x0000000000001ab8; 
        z = z * y / fixed_1; res += z * 0x000000000000017c; 
        z = z * y / fixed_1; res += z * 0x0000000000000014; 
        z = z * y / fixed_1; res += z * 0x0000000000000001; 
        res = res / 0x21c3677c82b40000 + y + fixed_1; 

        if ((x & 0x010000000000000000000000000000000) != 0) res = res * 0x1c3d6a24ed82218787d624d3e5eba95f9 / 0x18ebef9eac820ae8682b9793ac6d1e776; 
        if ((x & 0x020000000000000000000000000000000) != 0) res = res * 0x18ebef9eac820ae8682b9793ac6d1e778 / 0x1368b2fc6f9609fe7aceb46aa619baed4; 
        if ((x & 0x040000000000000000000000000000000) != 0) res = res * 0x1368b2fc6f9609fe7aceb46aa619baed5 / 0x0bc5ab1b16779be3575bd8f0520a9f21f; 
        if ((x & 0x080000000000000000000000000000000) != 0) res = res * 0x0bc5ab1b16779be3575bd8f0520a9f21e / 0x0454aaa8efe072e7f6ddbab84b40a55c9; 
        if ((x & 0x100000000000000000000000000000000) != 0) res = res * 0x0454aaa8efe072e7f6ddbab84b40a55c5 / 0x00960aadc109e7a3bf4578099615711ea; 
        if ((x & 0x200000000000000000000000000000000) != 0) res = res * 0x00960aadc109e7a3bf4578099615711d7 / 0x0002bf84208204f5977f9a8cf01fdce3d; 
        if ((x & 0x400000000000000000000000000000000) != 0) res = res * 0x0002bf84208204f5977f9a8cf01fdc307 / 0x0000003c6ab775dd0b95b4cbee7e65d11; 

        return res;
    }
}
