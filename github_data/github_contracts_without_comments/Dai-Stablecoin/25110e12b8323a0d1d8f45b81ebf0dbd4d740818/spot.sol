












pragma solidity >=0.5.0;

import ;

contract vatlike {
    function file(bytes32, bytes32, uint) external;
}

contract piplike {
    function peek() external returns (bytes32, bool);
}

contract spotter is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1;  }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        piplike pip;
        uint256 mat;
    }

    mapping (bytes32 => ilk) public ilks;

    vatlike public vat;
    uint256 public par; 

    
    event poke(
      bytes32 ilk,
      bytes32 val,
      uint256 spot
    );

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        par = one;
    }

    
    uint constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, one) / y;
    }

    
    function file(bytes32 ilk, bytes32 what, address pip_) external note auth {
        if (what == ) ilks[ilk].pip = piplike(pip_);
        else revert();
    }
    function file(bytes32 what, uint data) external note auth {
        if (what == ) par = data;
        else revert();
    }
    function file(bytes32 ilk, bytes32 what, uint data) external note auth {
        if (what == ) ilks[ilk].mat = data;
        else revert();
    }

    
    function poke(bytes32 ilk) external {
        (bytes32 val, bool zzz) = ilks[ilk].pip.peek();
        if (zzz) {
            uint256 spot = rdiv(rdiv(mul(uint(val), 10 ** 9), par), ilks[ilk].mat);
            vat.file(ilk, , spot);
            emit poke(ilk, val, spot);
        }
    }
}
