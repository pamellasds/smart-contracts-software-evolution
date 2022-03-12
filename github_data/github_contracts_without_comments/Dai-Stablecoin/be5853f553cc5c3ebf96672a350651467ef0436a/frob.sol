

pragma solidity ^0.4.24;

import ;

contract lad {
    bool  public live;
    vat   public  vat;
    int   public line;

    constructor(address vat_) public { vat = vat(vat_); live = true; }

    modifier auth { _; }  

    struct ilk {
        int256  spot;  
        int256  line;  
    }

    mapping (bytes32 => ilk) public ilks;

    function file(bytes32 what, int risk) public auth {
        if (what == ) line = risk;
    }
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].spot = risk;
        if (what == ) ilks[ilk].line = risk;
    }

    int256 constant one = 10 ** 27;
    function rmul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != 2**255);
        require(y == 0 || z / y == x);
        z = z / one;
    }

    function frob(bytes32 ilk, int dink, int dart) public {
        vat.tune(ilk, msg.sender, dink, dart);
        ilk storage i = ilks[ilk];

        (int rate, int art)           = vat.ilks(ilk);
        (int gem,  int ink,  int art) = vat.urns(ilk, msg.sender); gem;
        bool calm = rmul(art, rate) <= ilks[ilk].line && vat.tab() < line;
        bool cool = dart <= 0;
        bool firm = dink >= 0;
        bool safe = rmul(ink, i.spot) >= rmul(art, rate);

        require(( calm || cool ) && ( cool && firm || safe ) && live);
        require(rate != 0);
    }
}
