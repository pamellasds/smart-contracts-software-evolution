













pragma solidity >=0.5.0;

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
    function dai (address) public view returns (uint);
    function sin (address) public view returns (uint);
    function heal(address,address,int) public;
}

contract vow is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }


    
    address public vat;
    address public cow;  
    address public row;  

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public sump;  
    uint256 public bump;  
    uint256 public hump;  

    
    constructor() public { wards[msg.sender] = 1; }

    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) wait = data;
        if (what == ) bump = data;
        if (what == ) sump = data;
        if (what == ) hump = data;
    }
    function file(bytes32 what, address addr) public note auth {
        if (what == ) cow = addr;
        if (what == ) row = addr;
        if (what == )  vat = addr;
    }

    
    function awe() public view returns (uint) {
        return uint(vatlike(vat).sin(address(this)));
    }
    
    function joy() public view returns (uint) {
        return uint(vatlike(vat).dai(address(this)));
    }
    
    function woe() public view returns (uint) {
        return sub(sub(awe(), sin), ash);
    }

    
    function fess(uint tab) public note auth {
        sin[uint48(now)] = add(sin[uint48(now)], tab);
        sin = add(sin, tab);
    }
    
    function flog(uint48 era) public note {
        require(add(era, wait) <= now);
        sin = sub(sin, sin[era]);
        sin[era] = 0;
    }

    
    function heal(uint rad) public note {
        require(rad <= joy() && rad <= woe());
        require(int(rad) >= 0);
        vatlike(vat).heal(address(this), address(this), int(rad));
    }
    function kiss(uint rad) public note {
        require(rad <= ash && rad <= joy());
        ash = sub(ash, rad);
        require(int(rad) >= 0);
        vatlike(vat).heal(address(this), address(this), int(rad));
    }

    
    function flop() public returns (uint id) {
        require(woe() >= sump);
        require(joy() == 0);
        ash = add(ash, sump);
        return fusspot(row).kick(address(this), uint(1), sump);
    }
    
    function flap() public returns (uint id) {
        require(joy() >= add(add(awe(), bump), hump));
        require(woe() == 0);
        hopeful(fusspot(cow).dai()).hope(cow);
        id = fusspot(cow).kick(address(0), bump, 0);
        hopeful(fusspot(cow).dai()).nope(cow);
    }
}