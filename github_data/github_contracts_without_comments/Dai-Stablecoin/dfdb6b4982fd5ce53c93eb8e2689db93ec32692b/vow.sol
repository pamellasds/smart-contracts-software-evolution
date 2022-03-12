













pragma solidity >=0.5.0;

import ;

contract auction {
    function kick(address gal, uint lot, uint bid) public returns (uint);
    function cage(uint) public;
    function cage() public;
    function live() public returns (uint);
}

contract vatlike {
    function dai (address) public view returns (uint);
    function sin (address) public view returns (uint);
    function heal(uint256) public;
    function hope(address) public;
}

contract vow is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    vatlike public vat;
    auction public flapper;
    auction public flopper;

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public sump;  
    uint256 public bump;  
    uint256 public hump;  

    uint256 public live;

    
    constructor(address vat_, address flapper_, address flopper_) public {
        wards[msg.sender] = 1;
        vat     = vatlike(vat_);
        flapper = auction(flapper_);
        flopper = auction(flopper_);
        vat.hope(flapper_);
        live = 1;
    }

    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        if (x > y) { z = y; } else { z = x; }
    }

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) wait = data;
        if (what == ) bump = data;
        if (what == ) sump = data;
        if (what == ) hump = data;
    }

    
    function awe() public view returns (uint) {
        return vat.sin(address(this));
    }
    
    function joy() public view returns (uint) {
        return vat.dai(address(this));
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
        vat.heal(rad);
    }
    function kiss(uint rad) public note {
        require(rad <= ash && rad <= joy());
        ash = sub(ash, rad);
        vat.heal(rad);
    }

    
    function flop() public returns (uint id) {
        require(woe() >= sump);
        require(joy() == 0);
        ash = add(ash, sump);
        id = flopper.kick(address(this), uint(1), sump);
    }
    
    function flap() public returns (uint id) {
        require(joy() >= add(add(awe(), bump), hump));
        require(woe() == 0);
        id = flapper.kick(address(0), bump, 0);
    }

    function cage() public note auth {
        live = 0;
        sin = 0;
        ash = 0;
        flapper.cage(vat.dai(address(flapper)));
        flopper.cage();
        vat.heal(min(joy(), awe()));
    }
}
