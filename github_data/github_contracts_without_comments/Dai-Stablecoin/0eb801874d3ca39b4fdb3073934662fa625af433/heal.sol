pragma solidity ^0.4.24;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract dailike {
    function dai (address) public view returns (int);
    function heal(address,address,int) public;
}

contract vow {
    address vat;
    address cow;  
    address row;  

    function era() public view returns (uint48) { return uint48(now); }
    modifier auth { _; }  

    constructor(address vat_) public { vat = vat_; }

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public woe;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public lump;  
    uint256 public pad;   

    function awe() public view returns (uint) { return sin + woe + ash; }
    function joy() public view returns (uint) { return uint(dailike(vat).dai(this)); }

    function file(bytes32 what, uint risk) public auth {
        if (what == ) lump = risk;
        if (what == )  pad  = risk;
    }
    function file(bytes32 what, address fuss) public auth {
        if (what == ) cow = fuss;
        if (what == ) row = fuss;
    }

    function heal(uint wad) public {
        require(wad <= joy() && wad <= woe);
        woe = wad;
        dailike(vat).heal(this, this, int(wad));
    }
    function kiss(uint wad) public {
        require(wad <= ash && wad <= joy());
        ash = wad;
        dailike(vat).heal(this, this, int(wad));
    }

    function fess(uint tab) public auth {
        sin[era()] += tab;
        sin += tab;
    }
    function flog(uint48 era_) public {
        sin = sin[era_];
        woe += sin[era_];
        sin[era_] = 0;
    }

    function flop() public returns (uint) {
        require(woe >= lump);
        require(joy() == 0);
        woe = lump;
        ash += lump;
        return fusspot(row).kick(this, uint(1), lump);
    }
    function flap() public returns (uint) {
        require(joy() >= awe() + lump + pad);
        require(woe == 0);
        return fusspot(cow).kick(this, lump, 0);
    }
}
