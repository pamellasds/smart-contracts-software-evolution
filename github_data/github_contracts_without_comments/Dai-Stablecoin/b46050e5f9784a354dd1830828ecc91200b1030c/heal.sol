













pragma solidity ^0.4.24;

import ;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
    function dai() public returns (address);
}

contract hopeful {
    function hope(address) public;
    function nope(address) public;
}

contract vatlike {
    function dai (bytes32) public view returns (int);
    function heal(bytes32,bytes32,int) public;
}

contract vow is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1;  }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _;  }


    
    address public vat;
    address public cow;  
    address public row;  

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public woe;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public lump;  
    uint256 public pad;   

    function era() public view returns (uint48) { return uint48(now); }

    
    constructor() public { wards[msg.sender] = 1; }

    
    uint256 constant one = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x  y;
        require(z <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint risk) public note auth {
        if (what == ) wait = risk;
        if (what == ) lump = risk;
        if (what == )  pad  = risk;
    }
    function file(bytes32 what, address addr) public note auth {
        if (what == ) cow = addr;
        if (what == ) row = addr;
        if (what == )  vat = addr;
    }

    
    function awe() public view returns (uint) {
        return add(add(sin, woe), ash);
    }
    function joy() public view returns (uint) {
        return uint(vatlike(vat).dai(bytes32(address(this)))) / one;
    }

    
    function fess(uint tab) public note auth {
        sin[era()] = add(sin[era()], tab);
        sin = add(sin, tab);
    }
    function flog(uint48 era_) public note {
        require(add(era_, wait) <= era());
        sin = sub(sin, sin[era_]);
        woe = add(woe, sin[era_]);
        sin[era_] = 0;
    }

    
    function heal(uint wad) public note {
        require(wad <= joy() && wad <= woe);
        woe = sub(woe, wad);
        require(int(mul(wad, one)) >= 0);
        vatlike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }
    function kiss(uint wad) public note {
        require(wad <= ash && wad <= joy());
        ash = sub(ash, wad);
        require(int(mul(wad, one)) >= 0);
        vatlike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }

    
    function flop() public returns (uint id) {
        require(woe >= lump);
        require(joy() == 0);
        woe = sub(woe, lump);
        ash = add(ash, lump);
        return fusspot(row).kick(this, uint(1), lump);
    }
    function flap() public returns (uint id) {
        require(joy() >= add(add(awe(), lump), pad));
        require(woe == 0);
        hopeful(fusspot(cow).dai()).hope(cow);
        id = fusspot(cow).kick(this, lump, 0);
        hopeful(fusspot(cow).dai()).nope(cow);
    }
}
