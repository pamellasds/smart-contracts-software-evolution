














pragma solidity >=0.5.12;

import ;

interface vatlike {
    function dai(address) external view returns (uint256);
    function ilks(bytes32 ilk) external returns (
        uint256 art,   
        uint256 rate,  
        uint256 spot,  
        uint256 line,  
        uint256 dust   
    );
    function urns(bytes32 ilk, address urn) external returns (
        uint256 ink,   
        uint256 art    
    );
    function debt() external returns (uint256);
    function move(address src, address dst, uint256 rad) external;
    function hope(address) external;
    function flux(bytes32 ilk, address src, address dst, uint256 rad) external;
    function grab(bytes32 i, address u, address v, address w, int256 dink, int256 dart) external;
    function suck(address u, address v, uint256 rad) external;
    function cage() external;
}
interface catlike {
    function ilks(bytes32) external returns (
        address flip,
        uint256 chop,  
        uint256 lump   
    );
    function cage() external;
}
interface potlike {
    function cage() external;
}
interface vowlike {
    function cage() external;
}
interface flippy {
    function bids(uint id) external view returns (
        uint256 bid,   
        uint256 lot,   
        address guy,
        uint48  tic,   
        uint48  end,   
        address usr,
        address gal,
        uint256 tab    
    );
    function yank(uint id) external;
}

interface piplike {
    function read() external view returns (bytes32);
}

interface spotty {
    function par() external view returns (uint256);
    function ilks(bytes32) external view returns (
        piplike pip,
        uint256 mat    
    );
    function cage() external;
}



contract end is libnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    
    vatlike  public vat;   
    catlike  public cat;
    vowlike  public vow;   
    potlike  public pot;
    spotty   public spot;

    uint256  public live;  
    uint256  public when;  
    uint256  public wait;  
    uint256  public debt;  

    mapping (bytes32 => uint256) public tag;  
    mapping (bytes32 => uint256) public gap;  
    mapping (bytes32 => uint256) public art;  
    mapping (bytes32 => uint256) public fix;  

    mapping (address => uint256)                      public bag;  
    mapping (bytes32 => mapping (address => uint256)) public out;  

    
    constructor() public {
        wards[msg.sender] = 1;
        live = 1;
    }

    
    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    uint constant wad = 10 ** 18;
    uint constant ray = 10 ** 27;
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, y) / ray;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, ray) / y;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, wad) / y;
    }

    
    function file(bytes32 what, address data) external note auth {
        require(live == 1, );
        if (what == )  vat = vatlike(data);
        else if (what == )  cat = catlike(data);
        else if (what == )  vow = vowlike(data);
        else if (what == )  pot = potlike(data);
        else if (what == ) spot = spotty(data);
        else revert();
    }
    function file(bytes32 what, uint256 data) external note auth {
        require(live == 1, );
        if (what == ) wait = data;
        else revert();
    }

    
    function cage() external note auth {
        require(live == 1, );
        live = 0;
        when = now;
        vat.cage();
        cat.cage();
        vow.cage();
        spot.cage();
        pot.cage();
    }

    function cage(bytes32 ilk) external note {
        require(live == 0, );
        require(tag[ilk] == 0, );
        (art[ilk],,,,) = vat.ilks(ilk);
        (piplike pip,) = spot.ilks(ilk);
        
        tag[ilk] = wdiv(spot.par(), uint(pip.read()));
    }

    function skip(bytes32 ilk, uint256 id) external note {
        require(tag[ilk] != 0, );

        (address flipv,,) = cat.ilks(ilk);
        flippy flip = flippy(flipv);
        (, uint rate,,,) = vat.ilks(ilk);
        (uint bid, uint lot,,,, address usr,, uint tab) = flip.bids(id);

        vat.suck(address(vow), address(vow),  tab);
        vat.suck(address(vow), address(this), bid);
        vat.hope(address(flip));
        flip.yank(id);

        uint art = tab / rate;
        art[ilk] = add(art[ilk], art);
        require(int(lot) >= 0 && int(art) >= 0, );
        vat.grab(ilk, usr, address(this), address(vow), int(lot), int(art));
    }

    function skim(bytes32 ilk, address urn) external note {
        require(tag[ilk] != 0, );
        (, uint rate,,,) = vat.ilks(ilk);
        (uint ink, uint art) = vat.urns(ilk, urn);

        uint owe = rmul(rmul(art, rate), tag[ilk]);
        uint wad = min(ink, owe);
        gap[ilk] = add(gap[ilk], sub(owe, wad));

        require(wad <= 2**255 && art <= 2**255, );
        vat.grab(ilk, urn, address(this), address(vow), int(wad), int(art));
    }

    function free(bytes32 ilk) external note {
        require(live == 0, );
        (uint ink, uint art) = vat.urns(ilk, msg.sender);
        require(art == 0, );
        require(ink <= 2**255, );
        vat.grab(ilk, msg.sender, msg.sender, address(vow), int(ink), 0);
    }

    function thaw() external note {
        require(live == 0, );
        require(debt == 0, );
        require(vat.dai(address(vow)) == 0, );
        require(now >= add(when, wait), );
        debt = vat.debt();
    }
    function flow(bytes32 ilk) external note {
        require(debt != 0, );
        require(fix[ilk] == 0, );

        (, uint rate,,,) = vat.ilks(ilk);
        uint256 wad = rmul(rmul(art[ilk], rate), tag[ilk]);
        fix[ilk] = rdiv(mul(sub(wad, gap[ilk]), ray), debt);
    }

    function pack(uint256 wad) external note {
        require(debt != 0, );
        vat.move(msg.sender, address(vow), mul(wad, ray));
        bag[msg.sender] = add(bag[msg.sender], wad);
    }
    function cash(bytes32 ilk, uint wad) external note {
        require(fix[ilk] != 0, );
        vat.flux(ilk, address(this), msg.sender, rmul(wad, fix[ilk]));
        out[ilk][msg.sender] = add(out[ilk][msg.sender], wad);
        require(out[ilk][msg.sender] <= bag[msg.sender], );
    }
}
