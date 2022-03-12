














pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

contract vatlike {
    struct ilk {
        uint256 art;
        uint256 rate;
        uint256 spot;
        uint256 line;
        uint256 dust;
    }
    struct urn {
        uint256 ink;
        uint256 art;
    }
    function ilks(bytes32 ilk) public returns (ilk memory);
    function urns(bytes32 ilk, address urn) public returns (urn memory);
    function debt() public returns (uint);
    function move(address src, address dst, uint256 rad) public;
    function hope(address) public;
    function flux(bytes32 ilk, address src, address dst, uint256 rad) public;
    function grab(bytes32 i, address u, address v, address w, int256 dink, int256 dart) public;
    function suck(address u, address v, uint256 rad) public;
    function cage() public;
}
contract catlike {
    struct ilk {
        address flip;  
        uint256 chop;  
        uint256 lump;  
    }
    function ilks(bytes32) public returns (ilk memory);
    function cage() public;
}
contract vowlike {
    function joy() public view returns (uint);
    function heal(uint256 rad) public;
    function cage() public;
}
contract flippy {
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;
        uint48  tic;
        uint48  end;
        address urn;
        address gal;
        uint256 tab;
    }
    function bids(uint id) public view returns (bid memory);
    function yank(uint id) public;
}

contract piplike {
    function read() public view returns (bytes32);
}

contract spotty {
    struct ilk {
        piplike pip;
        uint256 mat;
    }
    function ilks(bytes32) public view returns (ilk memory);
}



contract end {
    
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    vatlike  public vat;
    catlike  public cat;
    vowlike  public vow;
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

    
    function file(bytes32 what, address data) public auth {
        if (what == )  vat = vatlike(data);
        if (what == )  cat = catlike(data);
        if (what == )  vow = vowlike(data);
        if (what == ) spot = spotty(data);
    }
    function file(bytes32 what, uint256 data) public auth {
        if (what == ) wait = data;
    }

    
    function cage() public auth {
        require(live == 1);
        live = 0;
        when = now;
        vat.cage();
        cat.cage();
        vow.cage();
    }

    function cage(bytes32 ilk) public {
        require(live == 0);
        require(tag[ilk] == 0);
        art[ilk] = vat.ilks(ilk).art;
        
        tag[ilk] = rdiv(wad, uint(spot.ilks(ilk).pip.read()));
    }

    function skip(bytes32 ilk, uint256 id) public {
        require(live == 0);

        flippy flip = flippy(cat.ilks(ilk).flip);
        vatlike.ilk memory i   = vat.ilks(ilk);
        flippy.bid  memory bid = flip.bids(id);

        vat.suck(address(vow), address(vow),  bid.tab);
        vat.suck(address(vow), address(this), bid.bid);
        vat.hope(address(flip));
        flip.yank(id);

        uint lot = bid.lot;
        uint art = bid.tab / i.rate;
        art[ilk] = add(art[ilk], art);
        require(int(lot) >= 0 && int(art) >= 0);
        vat.grab(ilk, bid.urn, address(this), address(vow), int(lot), int(art));
    }

    function skim(bytes32 ilk, address urn) public {
        require(tag[ilk] != 0);
        vatlike.ilk memory i = vat.ilks(ilk);
        vatlike.urn memory u = vat.urns(ilk, urn);

        uint owe = rmul(rmul(u.art, i.rate), tag[ilk]);
        uint wad = min(u.ink, owe);
        gap[ilk] = add(gap[ilk], sub(owe, wad));

        require(int(wad) <= 0 && int(u.art) <= 0);
        vat.grab(ilk, urn, address(this), address(vow), int(wad), int(u.art));
    }

    function free(bytes32 ilk) public {
        vatlike.urn memory u = vat.urns(ilk, msg.sender);
        require(u.art == 0);
        require(int(u.ink) < 0);
        vat.grab(ilk, msg.sender, msg.sender, address(vow), int(u.ink), 0);
    }

    function thaw() public {
        require(debt == 0);
        require(vow.joy() == 0);
        require(now >= when + wait);
        debt = vat.debt();
    }
    function flow(bytes32 ilk) public {
        require(debt != 0);
        require(fix[ilk] == 0);

        vatlike.ilk memory i = vat.ilks(ilk);
        uint256 wad = rmul(rmul(art[ilk], i.rate), tag[ilk]);
        fix[ilk] = rdiv(mul(sub(wad, gap[ilk]), ray), debt);
    }

    function pack(uint256 wad) public {
        require(debt != 0);
        vat.move(msg.sender, address(vow), mul(wad, ray));
        vow.heal(mul(wad, ray));
        bag[msg.sender] = add(bag[msg.sender], wad);
    }
    function cash(bytes32 ilk, uint wad) public {
        require(fix[ilk] != 0);
        vat.flux(ilk, address(this), msg.sender, rmul(wad, fix[ilk]));
        out[ilk][msg.sender] = add(out[ilk][msg.sender], wad);
        require(out[ilk][msg.sender] <= bag[msg.sender]);
    }
}
