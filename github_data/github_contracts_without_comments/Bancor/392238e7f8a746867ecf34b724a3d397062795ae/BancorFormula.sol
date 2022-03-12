pragma solidity ^0.4.11;
import ;
import ;

contract bancorformula is ibancorformula, utils {
    string public version = ;

    uint256 private constant one = 1;
    uint32 private constant max_crr = 1000000;
    uint8 private constant min_precision = 32;
    uint8 private constant max_precision = 127;

    
    uint256 private constant fixed_1 = 0x080000000000000000000000000000000;
    uint256 private constant fixed_2 = 0x100000000000000000000000000000000;
    uint256 private constant max_num = 0x1ffffffffffffffffffffffffffffffff;

    
    uint256 private constant ln2_mantissa = 0x2c5c85fdf473de6af278ece600fcbda;
    uint8   private constant ln2_exponent = 122;

    
    uint256[128] private maxexparray;

    function bancorformula() {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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

    
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _depositamount) public constant returns (uint256) {
        
        require(_supply > 0 && _reservebalance > 0 && _reserveratio > 0 && _reserveratio <= max_crr);

        
        if (_depositamount == 0)
            return 0;

        
        if (_reserveratio == max_crr)
            return safemul(_supply, _depositamount) / _reservebalance;

        uint256 basen = safeadd(_depositamount, _reservebalance);
        var (result, precision) = power(basen, _reservebalance, _reserveratio, max_crr);
        uint256 temp = safemul(_supply, result) >> precision;
        return temp  _supply;
     }

    
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint32 _reserveratio, uint256 _sellamount) public constant returns (uint256) {
        
        require(_supply > 0 && _reservebalance > 0 && _reserveratio > 0 && _reserveratio <= max_crr && _sellamount <= _supply);

        
        if (_sellamount == 0)
            return 0;

        
        if (_sellamount == _supply)
            return _reservebalance;

        
        if (_reserveratio == max_crr)
            return safemul(_reservebalance, _sellamount) / _supply;

        uint256 based = _supply  _sellamount;
        var (result, precision) = power(_supply, based, max_crr, _reserveratio);
        uint256 temp1 = safemul(_reservebalance, result);
        uint256 temp2 = _reservebalance << precision;
        return (temp1  temp2) / result;
    }

    
    function power(uint256 _basen, uint256 _based, uint32 _expn, uint32 _expd) internal constant returns (uint256, uint8) {
        uint256 lnbasetimesexp = ln(_basen, _based) * _expn / _expd;
        uint8 precision = findpositioninmaxexparray(lnbasetimesexp);
        return (fixedexp(lnbasetimesexp >> (max_precision  precision), precision), precision);
    }

    
    function ln(uint256 _numerator, uint256 _denominator) internal constant returns (uint256) {
        assert(_numerator <= max_num);

        uint256 res = 0;
        uint256 x = _numerator * fixed_1 / _denominator;

        
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

        return (res * ln2_mantissa) >> ln2_exponent;
    }

    
    function floorlog2(uint256 _n) internal constant returns (uint8) {
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

    
    function findpositioninmaxexparray(uint256 _x) internal constant returns (uint8) {
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

        assert(false);
        return 0;
    }

    
    function fixedexp(uint256 _x, uint8 _precision) internal constant returns (uint256) {
        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision;
        res += xi * 0x03442c4e6074a82f1797f72ac0000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0116b96f757c380fb287fd0e40000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0045ae5bdd5f0e03eca1ff4390000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000defabf91302cd95b9ffda50000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0002529ca9832b22439efff9b8000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000054f1cf12bd04e516b6da88000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000a9e39e257a09ca2d6db51000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000012e066e7b839fa050c309000000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000001e33d7d926c329a1ad1a800000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000002bee513bdb4a6b19b5f800000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000003a9316fa79b88eccf2a00000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000048177ebe1fa812375200000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000005263fe90242dcbacf00000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000057e22099c030d94100000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000057e22099c030d9410000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000052b6b54569976310000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000004985f67696bf748000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000003dea12ea99e498000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000031880f2214b6e000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000025bcff56eb36000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000001b722e10ab1000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000001317c70077000; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000cba84aafa00; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000082573a0a00; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000005035ad900; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000002f881b00; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000001b29340; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000000000efc40; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000007fe0; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000420; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000021; 
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000001; 

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (one << _precision); 
    }
}
