













pragma solidity ^0.4.24;

import ;

contract pit {
    vat   public  vat;
    int   public line;
    bool  public live;

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

    function mul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != 2**255);
        require(y == 0 || z / y == x);
    }

    int256 constant one = 10 ** 27;

    function frob(bytes32 ilk, int dink, int dart) public {
        bytes32 guy = bytes32(msg.sender);
        vat.tune(ilk, guy, guy, guy, dink, dart);

        (int rate, int art)           = vat.ilks(ilk);
        (int gem,  int ink,  int art) = vat.urns(ilk, bytes32(msg.sender)); gem;
        bool calm = mul(art, rate) <= mul(ilks[ilk].line, one) &&
                        vat.tab()  <  mul(line, one);
        bool safe = mul(ink, ilks[ilk].spot) >= mul(art, rate);

        require( ( calm || dart<=0 ) && ( dart<=0 && dink>=0 || safe ) && live);
        require(rate != 0);
    }
}
