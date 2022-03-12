pragma solidity ^0.4.23;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract vatlike {
    function dai(address guy) public view returns (int);
    function burn(uint wad) public;
    function grab(uint48 era_) public returns (uint);
}

contract vow {
    address vat;
    address cow;  
    address row;  

    modifier auth {
        
        _;
    }

    function era() public view returns (uint48) { return uint48(now); }

    constructor(address vat_) public { vat = vat_; }

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public woe;   
    uint256 public ash;   

    uint256 public lump;  
    uint256 public pad;   

    function awe() public view returns (uint) { return sin + woe + ash; }
    function joy() public view returns (uint) { return uint(vatlike(vat).dai(this)); }

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
        vatlike(vat).burn(wad);
    }
    function kiss(uint wad) public {
        require(wad <= ash && wad <= joy());
        ash = wad;
        vatlike(vat).burn(wad);
    }

    function grab(uint48 era_) public {
        uint tab = vatlike(vat).grab(era_);
        sin[era_] += tab;
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
