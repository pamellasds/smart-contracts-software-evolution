
pragma solidity 0.6.12;
import ;
import ;

contract bancorformula is ibancorformula {
    using safemath for uint256;

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

    
    uint256 private constant lambert_conv_radius = 0x002f16ac6c59de6f8d5d6f63c1482a7c86;
    uint256 private constant lambert_pos2_sample = 0x0003060c183060c183060c183060c18306;
    uint256 private constant lambert_pos2_maxval = 0x01af16ac6c59de6f8d5d6f63c1482a7c80;
    uint256 private constant lambert_pos3_maxval = 0x6b22d43e72c326539cceeef8bb48f255ff;

    
    uint256 private constant max_unf_weight = 0x10c6f7a0b5ed8d36b4c7f34938583621fafc8b0079a2834d26fa3fcc9ea9;

    
    uint256[128] private maxexparray;
    function initmaxexparray() private {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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

    
    uint256[128] private lambertarray;
    function initlambertarray() private {
        lambertarray[  0] = 0x60e393c68d20b1bd09deaabc0373b9c5;
        lambertarray[  1] = 0x5f8f46e4854120989ed94719fb4c2011;
        lambertarray[  2] = 0x5e479ebb9129fb1b7e72a648f992b606;
        lambertarray[  3] = 0x5d0bd23fe42dfedde2e9586be12b85fe;
        lambertarray[  4] = 0x5bdb29ddee979308ddfca81aeeb8095a;
        lambertarray[  5] = 0x5ab4fd8a260d2c7e2c0d2afcf0009dad;
        lambertarray[  6] = 0x5998b31359a55d48724c65cf09001221;
        lambertarray[  7] = 0x5885bcad2b322dfc43e8860f9c018cf5;
        lambertarray[  8] = 0x577b97aa1fe222bb452fdf111b1f0be2;
        lambertarray[  9] = 0x5679cb5e3575632e5baa27e2b949f704;
        lambertarray[ 10] = 0x557fe8241b3a31c83c732f1cdff4a1c5;
        lambertarray[ 11] = 0x548d868026504875d6e59bbe95fc2a6b;
        lambertarray[ 12] = 0x53a2465ce347cf34d05a867c17dd3088;
        lambertarray[ 13] = 0x52bdce5dcd4faed59c7f5511cf8f8acc;
        lambertarray[ 14] = 0x51dfcb453c07f8da817606e7885f7c3e;
        lambertarray[ 15] = 0x5107ef6b0a5a2be8f8ff15590daa3cce;
        lambertarray[ 16] = 0x5035f241d6eae0cd7bacba119993de7b;
        lambertarray[ 17] = 0x4f698fe90d5b53d532171e1210164c66;
        lambertarray[ 18] = 0x4ea288ca297a0e6a09a0eee240e16c85;
        lambertarray[ 19] = 0x4de0a13fdcf5d4213fc398ba6e3becde;
        lambertarray[ 20] = 0x4d23a145eef91fec06b06140804c4808;
        lambertarray[ 21] = 0x4c6b5430d4c1ee5526473db4ae0f11de;
        lambertarray[ 22] = 0x4bb7886c240562eba11f4963a53b4240;
        lambertarray[ 23] = 0x4b080f3f1cb491d2d521e0ea4583521e;
        lambertarray[ 24] = 0x4a5cbc96a05589cb4d86be1db3168364;
        lambertarray[ 25] = 0x49b566d40243517658d78c33162d6ece;
        lambertarray[ 26] = 0x4911e6a02e5507a30f947383fd9a3276;
        lambertarray[ 27] = 0x487216c2b31be4adc41db8a8d5cc0c88;
        lambertarray[ 28] = 0x47d5d3fc4a7a1b188cd3d788b5c5e9fc;
        lambertarray[ 29] = 0x473cfce4871a2c40bc4f9e1c32b955d0;
        lambertarray[ 30] = 0x46a771ca578ab878485810e285e31c67;
        lambertarray[ 31] = 0x4615149718aed4c258c373dc676aa72d;
        lambertarray[ 32] = 0x4585c8b3f8fe489c6e1833ca47871384;
        lambertarray[ 33] = 0x44f972f174e41e5efb7e9d63c29ce735;
        lambertarray[ 34] = 0x446ff970ba86d8b00beb05ecebf3c4dc;
        lambertarray[ 35] = 0x43e9438ec88971812d6f198b5ccaad96;
        lambertarray[ 36] = 0x436539d11ff7bea657aeddb394e809ef;
        lambertarray[ 37] = 0x42e3c5d3e5a913401d86f66db5d81c2c;
        lambertarray[ 38] = 0x4264d2395303070ea726cbe98df62174;
        lambertarray[ 39] = 0x41e84a9a593bb7194c3a6349ecae4eea;
        lambertarray[ 40] = 0x416e1b785d13eba07a08f3f18876a5ab;
        lambertarray[ 41] = 0x40f6322ff389d423ba9dd7e7e7b7e809;
        lambertarray[ 42] = 0x40807cec8a466880ecf4184545d240a4;
        lambertarray[ 43] = 0x400cea9ce88a8d3ae668e8ea0d9bf07f;
        lambertarray[ 44] = 0x3f9b6ae8772d4c55091e0ed7dfea0ac1;
        lambertarray[ 45] = 0x3f2bee253fd84594f54bcaafac383a13;
        lambertarray[ 46] = 0x3ebe654e95208bb9210c575c081c5958;
        lambertarray[ 47] = 0x3e52c1fc5665635b78ce1f05ad53c086;
        lambertarray[ 48] = 0x3de8f65ac388101ddf718a6f5c1eff65;
        lambertarray[ 49] = 0x3d80f522d59bd0b328ca012df4cd2d49;
        lambertarray[ 50] = 0x3d1ab193129ea72b23648a161163a85a;
        lambertarray[ 51] = 0x3cb61f68d32576c135b95cfb53f76d75;
        lambertarray[ 52] = 0x3c5332d9f1aae851a3619e77e4cc8473;
        lambertarray[ 53] = 0x3bf1e08edbe2aa109e1525f65759ef73;
        lambertarray[ 54] = 0x3b921d9cff13fa2c197746a3dfc4918f;
        lambertarray[ 55] = 0x3b33df818910bfc1a5aefb8f63ae2ac4;
        lambertarray[ 56] = 0x3ad71c1c77e34fa32a9f184967eccbf6;
        lambertarray[ 57] = 0x3a7bc9abf2c5bb53e2f7384a8a16521a;
        lambertarray[ 58] = 0x3a21dec7e76369783a68a0c6385a1c57;
        lambertarray[ 59] = 0x39c9525de6c9cdf7c1c157ca4a7a6ee3;
        lambertarray[ 60] = 0x39721bad3dc85d1240ff0190e0adaac3;
        lambertarray[ 61] = 0x391c324344d3248f0469eb28dd3d77e0;
        lambertarray[ 62] = 0x38c78df7e3c796279fb4ff84394ab3da;
        lambertarray[ 63] = 0x387426ea4638ae9aae08049d3554c20a;
        lambertarray[ 64] = 0x3821f57dbd2763256c1a99bbd2051378;
        lambertarray[ 65] = 0x37d0f256cb46a8c92ff62fbbef289698;
        lambertarray[ 66] = 0x37811658591ffc7abdd1feaf3cef9b73;
        lambertarray[ 67] = 0x37325aa10e9e82f7df0f380f7997154b;
        lambertarray[ 68] = 0x36e4b888cfb408d873b9a80d439311c6;
        lambertarray[ 69] = 0x3698299e59f4bb9de645fc9b08c64cca;
        lambertarray[ 70] = 0x364ca7a5012cb603023b57dd3ebfd50d;
        lambertarray[ 71] = 0x36022c928915b778ab1b06aaee7e61d4;
        lambertarray[ 72] = 0x35b8b28d1a73dc27500ffe35559cc028;
        lambertarray[ 73] = 0x357033e951fe250ec5eb4e60955132d7;
        lambertarray[ 74] = 0x3528ab2867934e3a21b5412e4c4f8881;
        lambertarray[ 75] = 0x34e212f66c55057f9676c80094a61d59;
        lambertarray[ 76] = 0x349c66289e5b3c4b540c24f42fa4b9bb;
        lambertarray[ 77] = 0x34579fbbd0c733a9c8d6af6b0f7d00f7;
        lambertarray[ 78] = 0x3413bad2e712288b924b5882b5b369bf;
        lambertarray[ 79] = 0x33d0b2b56286510ef730e213f71f12e9;
        lambertarray[ 80] = 0x338e82ce00e2496262c64457535ba1a1;
        lambertarray[ 81] = 0x334d26a96b373bb7c2f8ea1827f27a92;
        lambertarray[ 82] = 0x330c99f4f4211469e00b3e18c31475ea;
        lambertarray[ 83] = 0x32ccd87d6486094999c7d5e6f33237d8;
        lambertarray[ 84] = 0x328dde2dd617b6665a2e8556f250c1af;
        lambertarray[ 85] = 0x324fa70e9adc270f8262755af5a99af9;
        lambertarray[ 86] = 0x32122f443110611ca51040f41fa6e1e3;
        lambertarray[ 87] = 0x31d5730e42c0831482f0f1485c4263d8;
        lambertarray[ 88] = 0x31996ec6b07b4a83421b5ebc4ab4e1f1;
        lambertarray[ 89] = 0x315e1ee0a68ff46bb43ec2b85032e876;
        lambertarray[ 90] = 0x31237fe7bc4deacf6775b9efa1a145f8;
        lambertarray[ 91] = 0x30e98e7f1cc5a356e44627a6972ea2ff;
        lambertarray[ 92] = 0x30b04760b8917ec74205a3002650ec05;
        lambertarray[ 93] = 0x3077a75c803468e9132ce0cf3224241d;
        lambertarray[ 94] = 0x303fab57a6a275c36f19cda9bace667a;
        lambertarray[ 95] = 0x3008504beb8dcbd2cf3bc1f6d5a064f0;
        lambertarray[ 96] = 0x2fd19346ed17dac61219ce0c2c5ac4b0;
        lambertarray[ 97] = 0x2f9b7169808c324b5852fd3d54ba9714;
        lambertarray[ 98] = 0x2f65e7e711cf4b064eea9c08cbdad574;
        lambertarray[ 99] = 0x2f30f405093042ddff8a251b6bf6d103;
        lambertarray[100] = 0x2efc931a3750f2e8bfe323edfe037574;
        lambertarray[101] = 0x2ec8c28e46dbe56d98685278339400cb;
        lambertarray[102] = 0x2e957fd933c3926d8a599b602379b851;
        lambertarray[103] = 0x2e62c882c7c9ed4473412702f08ba0e5;
        lambertarray[104] = 0x2e309a221c12ba361e3ed695167feee2;
        lambertarray[105] = 0x2dfef25d1f865ae18dd07cfea4bcea10;
        lambertarray[106] = 0x2dcdcee821cdc80decc02c44344aeb31;
        lambertarray[107] = 0x2d9d2d8562b34944d0b201bb87260c83;
        lambertarray[108] = 0x2d6d0c04a5b62a2c42636308669b729a;
        lambertarray[109] = 0x2d3d6842c9a235517fc5a0332691528f;
        lambertarray[110] = 0x2d0e402963fe1ea2834abc408c437c10;
        lambertarray[111] = 0x2cdf91ae602647908aff975e4d6a2a8c;
        lambertarray[112] = 0x2cb15ad3a1eb65f6d74a75da09a1b6c5;
        lambertarray[113] = 0x2c8399a6ab8e9774d6fcff373d210727;
        lambertarray[114] = 0x2c564c4046f64edba6883ca06bbc4535;
        lambertarray[115] = 0x2c2970c431f952641e05cb493e23eed3;
        lambertarray[116] = 0x2bfd0560cd9eb14563bc7c0732856c18;
        lambertarray[117] = 0x2bd1084ed0332f7ff4150f9d0ef41a2c;
        lambertarray[118] = 0x2ba577d0fa1628b76d040b12a82492fb;
        lambertarray[119] = 0x2b7a5233cd21581e855e89dc2f1e8a92;
        lambertarray[120] = 0x2b4f95cd46904d05d72bdcde337d9cc7;
        lambertarray[121] = 0x2b2540fc9b4d9abba3faca6691914675;
        lambertarray[122] = 0x2afb5229f68d0830d8be8adb0a0db70f;
        lambertarray[123] = 0x2ad1c7c63a9b294c5bc73a3ba3ab7a2b;
        lambertarray[124] = 0x2aa8a04ac3cbe1ee1c9c86361465dbb8;
        lambertarray[125] = 0x2a7fda392d725a44a2c8aeb9ab35430d;
        lambertarray[126] = 0x2a57741b18cde618717792b4faa216db;
        lambertarray[127] = 0x2a2f6c81f5d84dd950a35626d6d5503a;
    }

    
    function init() public {
        initmaxexparray();
        initlambertarray();
    }

    
    function purchasetargetamount(uint256 _supply,
                                  uint256 _reservebalance,
                                  uint32 _reserveweight,
                                  uint256 _amount)
                                  public view override returns (uint256)
    {
        
        require(_supply > 0, );
        require(_reservebalance > 0, );
        require(_reserveweight > 0 && _reserveweight <= max_weight, );

        
        if (_amount == 0)
            return 0;

        
        if (_reserveweight == max_weight)
            return _supply.mul(_amount) / _reservebalance;

        uint256 result;
        uint8 precision;
        uint256 basen = _amount.add(_reservebalance);
        (result, precision) = power(basen, _reservebalance, _reserveweight, max_weight);
        uint256 temp = _supply.mul(result) >> precision;
        return temp  _supply;
    }

    
    function saletargetamount(uint256 _supply,
                              uint256 _reservebalance,
                              uint32 _reserveweight,
                              uint256 _amount)
                              public view override returns (uint256)
    {
        
        require(_supply > 0, );
        require(_reservebalance > 0, );
        require(_reserveweight > 0 && _reserveweight <= max_weight, );
        require(_amount <= _supply, );

        
        if (_amount == 0)
            return 0;

        
        if (_amount == _supply)
            return _reservebalance;

        
        if (_reserveweight == max_weight)
            return _reservebalance.mul(_amount) / _supply;

        uint256 result;
        uint8 precision;
        uint256 based = _supply  _amount;
        (result, precision) = power(_supply, based, max_weight, _reserveweight);
        uint256 temp1 = _reservebalance.mul(result);
        uint256 temp2 = _reservebalance << precision;
        return (temp1  temp2) / result;
    }

    
    function crossreservetargetamount(uint256 _sourcereservebalance,
                                      uint32 _sourcereserveweight,
                                      uint256 _targetreservebalance,
                                      uint32 _targetreserveweight,
                                      uint256 _amount)
                                      public view override returns (uint256)
    {
        
        require(_sourcereservebalance > 0 && _targetreservebalance > 0, );
        require(_sourcereserveweight > 0 && _sourcereserveweight <= max_weight &&
                _targetreserveweight > 0 && _targetreserveweight <= max_weight, );

        
        if (_sourcereserveweight == _targetreserveweight)
            return _targetreservebalance.mul(_amount) / _sourcereservebalance.add(_amount);

        uint256 result;
        uint8 precision;
        uint256 basen = _sourcereservebalance.add(_amount);
        (result, precision) = power(basen, _sourcereservebalance, _sourcereserveweight, _targetreserveweight);
        uint256 temp1 = _targetreservebalance.mul(result);
        uint256 temp2 = _targetreservebalance << precision;
        return (temp1  temp2) / result;
    }

    
    function fundcost(uint256 _supply,
                      uint256 _reservebalance,
                      uint32 _reserveratio,
                      uint256 _amount)
                      public view override returns (uint256)
    {
        
        require(_supply > 0, );
        require(_reservebalance > 0, );
        require(_reserveratio > 1 && _reserveratio <= max_weight * 2, );

        
        if (_amount == 0)
            return 0;

        
        if (_reserveratio == max_weight)
            return (_amount.mul(_reservebalance)  1) / _supply + 1;

        uint256 result;
        uint8 precision;
        uint256 basen = _supply.add(_amount);
        (result, precision) = power(basen, _supply, max_weight, _reserveratio);
        uint256 temp = ((_reservebalance.mul(result)  1) >> precision) + 1;
        return temp  _reservebalance;
    }

    
    function fundsupplyamount(uint256 _supply,
                              uint256 _reservebalance,
                              uint32 _reserveratio,
                              uint256 _amount)
                              public view override returns (uint256)
    {
        
        require(_supply > 0, );
        require(_reservebalance > 0, );
        require(_reserveratio > 1 && _reserveratio <= max_weight * 2, );

        
        if (_amount == 0)
            return 0;

        
        if (_reserveratio == max_weight)
            return _amount.mul(_supply) / _reservebalance;

        uint256 result;
        uint8 precision;
        uint256 basen = _reservebalance.add(_amount);
        (result, precision) = power(basen, _reservebalance, _reserveratio, max_weight);
        uint256 temp = _supply.mul(result) >> precision;
        return temp  _supply;
    }

    
    function liquidatereserveamount(uint256 _supply,
                                    uint256 _reservebalance,
                                    uint32 _reserveratio,
                                    uint256 _amount)
                                    public view override returns (uint256)
    {
        
        require(_supply > 0, );
        require(_reservebalance > 0, );
        require(_reserveratio > 1 && _reserveratio <= max_weight * 2, );
        require(_amount <= _supply, );

        
        if (_amount == 0)
            return 0;

        
        if (_amount == _supply)
            return _reservebalance;

        
        if (_reserveratio == max_weight)
            return _amount.mul(_reservebalance) / _supply;

        uint256 result;
        uint8 precision;
        uint256 based = _supply  _amount;
        (result, precision) = power(_supply, based, max_weight, _reserveratio);
        uint256 temp1 = _reservebalance.mul(result);
        uint256 temp2 = _reservebalance << precision;
        return (temp1  temp2) / result;
    }

    
    function balancedweights(uint256 _primaryreservestakedbalance,
                             uint256 _primaryreservebalance,
                             uint256 _secondaryreservebalance,
                             uint256 _reserveratenumerator,
                             uint256 _reserveratedenominator)
                             public view override returns (uint32, uint32)
    {
        if (_primaryreservestakedbalance == _primaryreservebalance)
            require(_primaryreservestakedbalance > 0 || _secondaryreservebalance > 0, );
        else
            require(_primaryreservestakedbalance > 0 && _primaryreservebalance > 0 && _secondaryreservebalance > 0, );
        require(_reserveratenumerator > 0 && _reserveratedenominator > 0, );

        uint256 tq = _primaryreservestakedbalance.mul(_reserveratenumerator);
        uint256 rp = _secondaryreservebalance.mul(_reserveratedenominator);

        if (_primaryreservestakedbalance < _primaryreservebalance)
            return balancedweightsbystake(_primaryreservebalance, _primaryreservestakedbalance, tq, rp, true);

        if (_primaryreservestakedbalance > _primaryreservebalance)
            return balancedweightsbystake(_primaryreservestakedbalance, _primaryreservebalance, tq, rp, false);

        return normalizedweights(tq, rp);
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

    
    function lowerstake(uint256 _x) internal view returns (uint256) {
        if (_x <= lambert_conv_radius)
            return lambertpos1(_x);
        if (_x <= lambert_pos2_maxval)
            return lambertpos2(_x);
        if (_x <= lambert_pos3_maxval)
            return lambertpos3(_x);
        require(false);
    }

    
    function higherstake(uint256 _x) internal pure returns (uint256) {
        if (_x <= lambert_conv_radius)
            return lambertneg1(_x);
        return fixed_1 * fixed_1 / _x;
    }

    
    function lambertpos1(uint256 _x) internal pure returns (uint256) {
        uint256 xi = _x;
        uint256 res = (fixed_1  _x) * 0xde1bc4d19efcac82445da75b00000000; 

        xi = (xi * _x) / fixed_1; res += xi * 0x00000000014d29a73a6e7b02c3668c7b0880000000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x0000000002504a0cd9a7f7215b60f9be4800000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000000484d0a1191c0ead267967c7a4a0000000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x00000000095ec580d7e8427a4baf26a90a00000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000001440b0be1615a47dba6e5b3b1f10000000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x000000002d207601f46a99b4112418400000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000066ebaac4c37c622dd8288a7eb1b2000000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x00000000ef17240135f7dbd43a1ba10cf200000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000233c33c676a5eb2416094a87b3657000000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x0000000541cde48bc0254bed49a9f8700000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000cae1fad2cdd4d4cb8d73abca0d19a400000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x0000001edb2aa2f760d15c41ceedba956400000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000004ba8d20d2dabd386c9529659841a2e200000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x000000bac08546b867cdaa20000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000001cfa8e70c03625b9db76c8ebf5bbf24820000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x000004851d99f82060df265f3309b26f8200000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00000b550d19b129d270c44f6f55f027723cbb0000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x00001c877dadc761dc272deb65d4b0000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000048178ece97479f33a77f2ad22a81b64406c000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x0000b6ca8268b9d810fedf6695ef2f8a6c00000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0001d0e76631a5b05d007b8cb72a7c7f11ec36e000; 
        xi = (xi * _x) / fixed_1; res = xi * 0x0004a1c37bd9f85fd9c6c780000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000bd8369f1b702bf491e2ebfcee08250313b65400; 
        xi = (xi * _x) / fixed_1; res = xi * 0x001e5c7c32a9f6c70ab2cb59d9225764d400000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x004dff5820e165e910f95120a708e742496221e600; 
        xi = (xi * _x) / fixed_1; res = xi * 0x00c8c8f66db1fced378ee50e536000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0205db8dffff45bfa2938f128f599dbf16eb11d880; 
        xi = (xi * _x) / fixed_1; res = xi * 0x053a044ebd984351493e1786af38d39a0800000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0d86dae2a4cc0f47633a544479735869b487b59c40; 
        xi = (xi * _x) / fixed_1; res = xi * 0x231000000000000000000000000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x5b0485a76f6646c2039db1507cdd51b08649680822; 
        xi = (xi * _x) / fixed_1; res = xi * 0xec983c46c49545bc17efa6b5b0055e242200000000; 

        return res / 0xde1bc4d19efcac82445da75b00000000; 
    }

    
    function lambertpos2(uint256 _x) internal view returns (uint256) {
        uint256 x = _x  lambert_conv_radius  1;
        uint256 i = x / lambert_pos2_sample;
        uint256 a = lambert_pos2_sample * i;
        uint256 b = lambert_pos2_sample * (i + 1);
        uint256 c = lambertarray[i];
        uint256 d = lambertarray[i + 1];
        return (c * (b  x) + d * (x  a)) / lambert_pos2_sample;
    }

    
    function lambertpos3(uint256 _x) internal pure returns (uint256) {
        uint256 l1 = _x < opt_log_max_val ? optimallog(_x) : generallog(_x);
        uint256 l2 = l1 < opt_log_max_val ? optimallog(l1) : generallog(l1);
        return (l1  l2 + l2 * fixed_1 / l1) * fixed_1 / _x;
    }

    
    function lambertneg1(uint256 _x) internal pure returns (uint256) {
        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) / fixed_1; res += xi * 0x00000000014d29a73a6e7b02c3668c7b0880000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000002504a0cd9a7f7215b60f9be4800000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000000484d0a1191c0ead267967c7a4a0000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00000000095ec580d7e8427a4baf26a90a00000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000001440b0be1615a47dba6e5b3b1f10000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000002d207601f46a99b4112418400000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000066ebaac4c37c622dd8288a7eb1b2000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00000000ef17240135f7dbd43a1ba10cf200000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000233c33c676a5eb2416094a87b3657000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000541cde48bc0254bed49a9f8700000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000000cae1fad2cdd4d4cb8d73abca0d19a400000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000001edb2aa2f760d15c41ceedba956400000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000004ba8d20d2dabd386c9529659841a2e200000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000000bac08546b867cdaa20000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000001cfa8e70c03625b9db76c8ebf5bbf24820000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000004851d99f82060df265f3309b26f8200000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00000b550d19b129d270c44f6f55f027723cbb0000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00001c877dadc761dc272deb65d4b0000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000048178ece97479f33a77f2ad22a81b64406c000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0000b6ca8268b9d810fedf6695ef2f8a6c00000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0001d0e76631a5b05d007b8cb72a7c7f11ec36e000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0004a1c37bd9f85fd9c6c780000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x000bd8369f1b702bf491e2ebfcee08250313b65400; 
        xi = (xi * _x) / fixed_1; res += xi * 0x001e5c7c32a9f6c70ab2cb59d9225764d400000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x004dff5820e165e910f95120a708e742496221e600; 
        xi = (xi * _x) / fixed_1; res += xi * 0x00c8c8f66db1fced378ee50e536000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0205db8dffff45bfa2938f128f599dbf16eb11d880; 
        xi = (xi * _x) / fixed_1; res += xi * 0x053a044ebd984351493e1786af38d39a0800000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x0d86dae2a4cc0f47633a544479735869b487b59c40; 
        xi = (xi * _x) / fixed_1; res += xi * 0x231000000000000000000000000000000000000000; 
        xi = (xi * _x) / fixed_1; res += xi * 0x5b0485a76f6646c2039db1507cdd51b08649680822; 
        xi = (xi * _x) / fixed_1; res += xi * 0xec983c46c49545bc17efa6b5b0055e242200000000; 

        return res / 0xde1bc4d19efcac82445da75b00000000 + _x + fixed_1; 
    }

    
    function balancedweightsbystake(uint256 _hi, uint256 _lo, uint256 _tq, uint256 _rp, bool _lowerstake) internal view returns (uint32, uint32) {
        (_tq, _rp) = safefactors(_tq, _rp);
        uint256 f = _hi.mul(fixed_1) / _lo;
        uint256 g = f < opt_log_max_val ? optimallog(f) : generallog(f);
        uint256 x = g.mul(_tq) / _rp;
        uint256 y = _lowerstake ? lowerstake(x) : higherstake(x);
        return normalizedweights(y.mul(_tq), _rp.mul(fixed_1));
    }

    
    function safefactors(uint256 _a, uint256 _b) internal pure returns (uint256, uint256) {
        if (_a <= fixed_2 && _b <= fixed_2)
            return (_a, _b);
        if (_a < fixed_2)
            return (_a * fixed_2 / _b, fixed_2);
        if (_b < fixed_2)
            return (fixed_2, _b * fixed_2 / _a);
        uint256 c = _a > _b ? _a : _b;
        uint256 n = floorlog2(c / fixed_1);
        return (_a >> n, _b >> n);
    }

    
    function normalizedweights(uint256 _a, uint256 _b) internal pure returns (uint32, uint32) {
        if (_a <= _b)
            return accurateweights(_a, _b);
        (uint32 y, uint32 x) = accurateweights(_b, _a);
        return (x, y);
    }

    
    function accurateweights(uint256 _a, uint256 _b) internal pure returns (uint32, uint32) {
        if (_a > max_unf_weight) {
            uint256 c = _a / (max_unf_weight + 1) + 1;
            _a /= c;
            _b /= c;
        }
        uint256 x = rounddiv(_a * max_weight, _a.add(_b));
        uint256 y = max_weight  x;
        return (uint32(x), uint32(y));
    }

    
    function rounddiv(uint256 _n, uint256 _d) internal pure returns (uint256) {
        return _n / _d + _n % _d / (_d  _d / 2);
    }

    
    function calculatepurchasereturn(uint256 _supply,
                                     uint256 _reservebalance,
                                     uint32 _reserveweight,
                                     uint256 _amount)
                                     public view returns (uint256)
    {
        return purchasetargetamount(_supply, _reservebalance, _reserveweight, _amount);
    }

    
    function calculatesalereturn(uint256 _supply,
                                 uint256 _reservebalance,
                                 uint32 _reserveweight,
                                 uint256 _amount)
                                 public view returns (uint256)
    {
        return saletargetamount(_supply, _reservebalance, _reserveweight, _amount);
    }

    
    function calculatecrossreservereturn(uint256 _sourcereservebalance,
                                         uint32 _sourcereserveweight,
                                         uint256 _targetreservebalance,
                                         uint32 _targetreserveweight,
                                         uint256 _amount)
                                         public view returns (uint256)
    {
        return crossreservetargetamount(_sourcereservebalance, _sourcereserveweight, _targetreservebalance, _targetreserveweight, _amount);
    }

    
    function calculatecrossconnectorreturn(uint256 _sourcereservebalance,
                                           uint32 _sourcereserveweight,
                                           uint256 _targetreservebalance,
                                           uint32 _targetreserveweight,
                                           uint256 _amount)
                                           public view returns (uint256)
    {
        return crossreservetargetamount(_sourcereservebalance, _sourcereserveweight, _targetreservebalance, _targetreserveweight, _amount);
    }

    
    function calculatefundcost(uint256 _supply,
                               uint256 _reservebalance,
                               uint32 _reserveratio,
                               uint256 _amount)
                               public view returns (uint256)
    {
        return fundcost(_supply, _reservebalance, _reserveratio, _amount);
    }

    
    function calculateliquidatereturn(uint256 _supply,
                                      uint256 _reservebalance,
                                      uint32 _reserveratio,
                                      uint256 _amount)
                                      public view returns (uint256)
    {
        return liquidatereserveamount(_supply, _reservebalance, _reserveratio, _amount);
    }

    
    function purchaserate(uint256 _supply,
                          uint256 _reservebalance,
                          uint32 _reserveweight,
                          uint256 _amount)
                          public view returns (uint256)
    {
        return purchasetargetamount(_supply, _reservebalance, _reserveweight, _amount);
    }

    
    function salerate(uint256 _supply,
                      uint256 _reservebalance,
                      uint32 _reserveweight,
                      uint256 _amount)
                      public view returns (uint256)
    {
        return saletargetamount(_supply, _reservebalance, _reserveweight, _amount);
    }

    
    function crossreserverate(uint256 _sourcereservebalance,
                              uint32 _sourcereserveweight,
                              uint256 _targetreservebalance,
                              uint32 _targetreserveweight,
                              uint256 _amount)
                              public view returns (uint256)
    {
        return crossreservetargetamount(_sourcereservebalance, _sourcereserveweight, _targetreservebalance, _targetreserveweight, _amount);
    }

    
    function liquidaterate(uint256 _supply,
                           uint256 _reservebalance,
                           uint32 _reserveratio,
                           uint256 _amount)
                           public view returns (uint256)
    {
        return liquidatereserveamount(_supply, _reservebalance, _reserveratio, _amount);
    }
}
