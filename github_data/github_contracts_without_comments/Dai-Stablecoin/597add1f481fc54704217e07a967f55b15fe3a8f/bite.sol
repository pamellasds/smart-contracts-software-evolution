













pragma solidity ^0.4.24;

contract flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vatlike {
    function ilks(bytes32) public view returns (int,int);
    function urns(bytes32,address) public view returns (int,int,int);
    function grab(bytes32,address,address,int,int) public returns (uint);
}

contract ladlike {
    function ilks(bytes32) public view returns (int,int);
}

contract vowlike {
    function fess(uint) public;
}

contract cat {
    address public vat;
    address public lad;
    address public vow;
    uint256 public lump;  

    modifier auth { _; }  

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

    uint256                   public nflip;
    mapping (uint256 => flip) public flips;

    constructor(address vat_, address lad_, address vow_) public {
        vat = vat_;
        lad = lad_;
        vow = vow_;
    }

    function file(bytes32 what, uint risk) public auth {
        if (what == ) lump = risk;
    }
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].chop = risk;
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flip;
    }

    function bite(bytes32 ilk, address guy) public returns (uint) {
        (int rate, int art)           = vatlike(vat).ilks(ilk); art;
        (int spot, int line)          = ladlike(lad).ilks(ilk); line;
        (int gem , int ink , int art) = vatlike(vat).urns(ilk, guy); gem;
        int tab = rmul(art, rate);

        require(rmul(ink, spot) < tab);  

        vatlike(vat).grab(ilk, guy, vow, ink, art);
        vowlike(vow).fess(uint(tab));

        flips[nflip] = flip(ilk, guy, uint(ink), uint(tab));

        return nflip++;
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
                                   , gal: vow
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
