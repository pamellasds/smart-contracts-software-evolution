













pragma solidity >=0.5.12;

import ;

interface kicker {
    function kick(address urn, address gal, uint tab, uint lot, uint bid)
        external returns (uint);
}

interface vatlike {
    function ilks(bytes32) external view returns (
        uint256 art,   
        uint256 rate,  
        uint256 spot   
    );
    function urns(bytes32,address) external view returns (
        uint256 ink,   
        uint256 art    
    );
    function grab(bytes32,address,address,address,int,int) external;
    function hope(address) external;
    function nope(address) external;
}

interface vowlike {
    function fess(uint) external;
}

contract cat is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    
    struct ilk {
        address flip;  
        uint256 chop;  
        uint256 lump;  
    }

    mapping (bytes32 => ilk) public ilks;

    uint256 public live;  
    vatlike public vat;   
    vowlike public vow;   

    
    event bite(
      bytes32 indexed ilk,
      address indexed urn,
      uint256 ink,
      uint256 art,
      uint256 tab,
      address flip,
      uint256 id
    );

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        live = 1;
    }

    
    uint constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, y) / one;
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        if (x > y) { z = y; } else { z = x; }
    }

    
    function file(bytes32 what, address data) external note auth {
        if (what == ) vow = vowlike(data);
        else revert();
    }
    function file(bytes32 ilk, bytes32 what, uint data) external note auth {
        if (what == ) ilks[ilk].chop = data;
        else if (what == ) ilks[ilk].lump = data;
        else revert();
    }
    function file(bytes32 ilk, bytes32 what, address flip) external note auth {
        if (what == ) {
            vat.nope(ilks[ilk].flip);
            ilks[ilk].flip = flip;
            vat.hope(flip);
        }
        else revert();
    }

    
    function bite(bytes32 ilk, address urn) external returns (uint id) {
        (, uint rate, uint spot) = vat.ilks(ilk);
        (uint ink, uint art) = vat.urns(ilk, urn);

        require(live == 1, );
        require(spot > 0 && mul(ink, spot) < mul(art, rate), );

        uint lot = min(ink, ilks[ilk].lump);
        art      = min(art, mul(lot, art) / ink);

        require(lot <= 2**255 && art <= 2**255, );
        vat.grab(ilk, urn, address(this), address(vow), int(lot), int(art));

        vow.fess(mul(art, rate));
        id = kicker(ilks[ilk].flip).kick({ urn: urn
                                         , gal: address(vow)
                                         , tab: rmul(mul(art, rate), ilks[ilk].chop)
                                         , lot: lot
                                         , bid: 0
                                         });

        emit bite(ilk, urn, lot, art, mul(art, rate), ilks[ilk].flip, id);
    }

    function cage() external note auth {
        live = 0;
    }
}
