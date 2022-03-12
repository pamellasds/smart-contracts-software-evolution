













pragma solidity >=0.5.12;

import ;

interface kicker {
    function kick(address urn, address gal, uint256 tab, uint256 lot, uint256 bid)
        external returns (uint256);
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
    function grab(bytes32,address,address,address,int256,int256) external;
    function hope(address) external;
    function nope(address) external;
}

interface vowlike {
    function fess(uint256) external;
}

contract cat is libnote {
    
    mapping (address => uint256) public wards;
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
    uint256 public box;    
    uint256 public litter; 

    
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

    
    uint256 constant ray = 10 ** 27;

    uint256 constant max_lump = uint256(1) / ray;

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        if (x > y) { z = y; } else { z = x; }
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x  y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, address data) external note auth {
        if (what == ) vow = vowlike(data);
        else revert();
    }
    function file(bytes32 what, uint256 data) external note auth {
        if (what == ) box = data;
        else revert();
    }
    function file(bytes32 ilk, bytes32 what, uint256 data) external note auth {
        if (what == ) ilks[ilk].chop = data;
        else if (what ==  && data <= max_lump) ilks[ilk].lump = data;
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

    
    function bite(bytes32 ilk, address urn) external returns (uint256 id) {
        (, uint256 rate, uint256 spot) = vat.ilks(ilk);
        (uint256 ink, uint256 art) = vat.urns(ilk, urn);

        require(live == 1, );
        require(spot > 0 && mul(ink, spot) < mul(art, rate), );
        require(litter < box, );

        ilk memory milk = ilks[ilk];

        uint256 limit = min(milk.lump, sub(box, litter));
        uint256 fart = min(art, mul(limit, ray) / rate / milk.chop);
        uint256 fink = min(ink, mul(ink, fart) / art);

        require(fink <= 2**255 && fart <= 2**255, );
        vat.grab(ilk, urn, address(this), address(vow), int256(fink), int256(fart));
        vow.fess(mul(fart, rate));

        { 
            uint256 tab = mul(mul(fart, rate), milk.chop) / ray;
            litter = add(litter, tab);

            id = kicker(milk.flip).kick({
                urn: urn,
                gal: address(vow),
                tab: tab,
                lot: fink,
                bid: 0
            });
        }

        emit bite(ilk, urn, fink, fart, mul(fart, rate), milk.flip, id);
    }

    function scoop(uint256 poop) external note auth {
        litter = sub(litter, poop);
    }

    function cage() external note auth {
        live = 0;
    }
}
