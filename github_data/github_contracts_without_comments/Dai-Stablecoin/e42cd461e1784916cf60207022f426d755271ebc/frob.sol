













pragma solidity ^0.4.24;

import ;

contract pit {
    vat   public  vat;
    uint  public line;
    bool  public live;

    constructor(address vat_) public { vat = vat(vat_); live = true; }

    modifier auth { _; }  

    struct ilk {
        uint256  spot;  
        uint256  line;  
    }

    mapping (bytes32 => ilk) public ilks;

    function file(bytes32 what, uint risk) public auth {
        if (what == ) line = risk;
    }
    function file(bytes32 ilk, bytes32 what, uint risk) public auth {
        if (what == ) ilks[ilk].spot = risk;
        if (what == ) ilks[ilk].line = risk;
    }

    uint256 constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function frob(bytes32 ilk, int dink, int dart) public {
        bytes32 guy = bytes32(msg.sender);
        vat.tune(ilk, guy, guy, guy, dink, dart);

        (uint rate, uint art) = vat.ilks(ilk);
        (uint ink,  uint art) = vat.urns(ilk, bytes32(msg.sender));
        bool calm = mul(art, rate) <= mul(ilks[ilk].line, one) &&
                        vat.tab()  <  mul(line, one);
        bool safe = mul(ink, ilks[ilk].spot) >= mul(art, rate);

        require( ( calm || dart<=0 ) && ( dart<=0 && dink>=0 || safe ) && live);
        require(rate != 0);
    }
}
