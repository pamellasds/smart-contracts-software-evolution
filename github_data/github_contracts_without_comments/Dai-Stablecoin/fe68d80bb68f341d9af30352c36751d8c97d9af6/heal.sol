pragma solidity ^0.4.23;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract vatlike {
    function ilks(bytes32) public view returns (int,int);
    function urns(bytes32,address) public view returns (int,int,int);
    function dai(address) public view returns (int);
    function burn(uint) public;
    function grab(bytes32,address,address,int,int) public returns (uint);
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

    uint256 public wait;  
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
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].chop = risk;
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flip;
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


    struct ilk {
        int256  chop;
        address flip;
    }
    mapping (bytes32 => ilk) public ilks;

    struct flip {
        bytes32 ilk;
        address lad;
        uint256 ink;
        uint256 tab;
    }
    flip[] public flips;

    function bite(bytes32 ilk, address lad) public returns (uint) {
        (int spot, int rate) = vatlike(vat).ilks(ilk);
        (int gem , int ink, int art) = vatlike(vat).urns(ilk, lad);
        gem;
        int tab = rmul(art, rate);

        require(rmul(ink, spot) < tab);  

        vatlike(vat).grab(ilk, lad, this, ink, art);

        sin[era()] += uint(tab);
        sin += uint(tab);
        return flips.push(flip(ilk, lad, uint(ink), uint(tab)))  1;
    }

    function flip(uint n, uint wad) public returns (uint) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == lump || (wad < lump && wad == f.tab));

        uint tab = f.tab;
        uint ink = f.ink * wad / tab;

        f.tab = wad;
        f.ink = ink;

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: this
                                   , tab: uint(rmul(int(wad), i.chop))
                                   , lot: uint(ink)
                                   , bid: uint(0)
                                   });
    }

    int constant ray = 10 ** 27;
    function rmul(int x, int y) internal pure returns (int z) {
        z = x * y / ray;
    }
}

contract flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}
