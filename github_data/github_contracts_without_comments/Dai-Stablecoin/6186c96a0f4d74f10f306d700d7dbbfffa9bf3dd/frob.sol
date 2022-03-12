













pragma solidity ^0.4.24;

import ;

contract drip {
    function drip(bytes32) public;
}

contract pit {
    vat   public  vat;
    uint  public line;
    bool  public live;
    drip  public drip;

    mapping (address => bool) public wards;
    function rely(address guy) public auth { wards[guy] = true;  }
    function deny(address guy) public auth { wards[guy] = false; }
    modifier auth { require(wards[msg.sender]); _;  }

    constructor(address vat_) public {
        wards[msg.sender] = true;
        vat = vat(vat_);
        live = true;
    }

    struct ilk {
        uint256  spot;  
        uint256  line;  
    }

    mapping (bytes32 => ilk) public ilks;

    function file(bytes32 what, address drip_) public auth {
        if (what == ) drip = drip(drip_);
    }
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
        drip.drip(ilk);
        bytes32 guy = bytes32(msg.sender);
        vat.tune(ilk, guy, guy, guy, dink, dart);

        (uint rate, uint art) = vat.ilks(ilk);
        (uint ink,  uint art) = vat.urns(ilk, bytes32(msg.sender));
        bool calm = mul(art, rate) <= mul(ilks[ilk].line, one) &&
                        vat.debt() <  mul(line, one);
        bool safe = mul(ink, ilks[ilk].spot) >= mul(art, rate);

        require( ( calm || dart<=0 ) && ( dart<=0 && dink>=0 || safe ) && live);
        require(rate != 0);
    }
}
