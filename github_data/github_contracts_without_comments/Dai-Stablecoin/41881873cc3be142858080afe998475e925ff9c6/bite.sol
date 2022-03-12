













pragma solidity ^0.4.24;

contract flippy{
    function kick(bytes32 lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vatlike {
    function ilks(bytes32) public view returns (uint,uint);
    function urns(bytes32,bytes32) public view returns (uint,uint);
    function grab(bytes32,bytes32,bytes32,bytes32,int,int) public returns (uint);
}

contract pitlike {
    function ilks(bytes32) public view returns (uint,uint);
}

contract vowlike {
    function fess(uint) public;
}

contract cat {
    
    mapping (address => bool) public wards;
    function rely(address guy) public auth { wards[guy] = true;  }
    function deny(address guy) public auth { wards[guy] = false; }
    modifier auth { require(wards[msg.sender]); _;  }

    
    struct ilk {
        uint256 chop;
        address flip;
    }
    struct flip {
        bytes32 ilk;
        bytes32 lad;
        uint256 ink;
        uint256 tab;
    }

    mapping (bytes32 => ilk)  public ilks;
    mapping (uint256 => flip) public flips;
    uint256                   public nflip;

    address public vat;
    address public pit;
    address public vow;
    uint256 public lump;  

    
    constructor(address vat_, address pit_, address vow_) public {
        wards[msg.sender] = true;
        vat = vat_;
        pit = pit_;
        vow = vow_;
    }

    
    uint constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / one;
    }

    
    function file(bytes32 what, uint risk) public auth {
        if (what == ) lump = risk;
    }
    function file(bytes32 ilk, bytes32 what, uint risk) public auth {
        if (what == ) ilks[ilk].chop = risk;
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flip;
    }

    
    function bite(bytes32 ilk, bytes32 guy) public returns (uint) {
        (uint rate, uint art)           = vatlike(vat).ilks(ilk); art;
        (uint spot, uint line)          = pitlike(pit).ilks(ilk); line;
        (uint ink , uint art) = vatlike(vat).urns(ilk, guy);
        uint tab = rmul(art, rate);

        require(rmul(ink, spot) < tab);  

        vatlike(vat).grab(ilk, guy, bytes32(address(this)), bytes32(vow), int(ink), int(art));
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
        uint ink = mul(f.ink, wad) / tab;

        f.tab = wad;
        f.ink = ink;

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: vow
                                   , tab: uint(rmul(wad, i.chop))
                                   , lot: uint(ink)
                                   , bid: uint(0)
                                   });
    }
}
