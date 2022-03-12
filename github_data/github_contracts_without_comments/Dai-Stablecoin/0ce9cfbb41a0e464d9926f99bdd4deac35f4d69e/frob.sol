

pragma solidity ^0.4.23;

contract gemlike {
    function move(address,address,uint) public;
}

contract flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vat {
    address public root;
    bool    public live;
    uint256 public forms;

    int256  public line;
    int256  public lump;
    uint48  public wait;

    modifier auth {
        
        _;
    }

    struct ilk {
        int256  spot;  
        int256  rate;  
        int256  line;  
        int256  chop;  

        int256  art;   

        address  flip;
    }
    struct urn {
        int256 gem;
        int256 ink;
        int256 art;
    }

    mapping (address => int256)                   public dai;
    mapping (bytes32 => ilk)                      public ilks;
    mapping (bytes32 => mapping (address => urn)) public urns;

    function gem(bytes32 ilk, address lad) public view returns (int) {
        return urns[ilk][lad].gem;
    }
    function ink(bytes32 ilk, address lad) public view returns (int) {
        return urns[ilk][lad].ink;
    }
    function art(bytes32 ilk, address lad) public view returns (int) {
        return urns[ilk][lad].art;
    }
    int public tab;

    function era() public view returns (uint48) { return uint48(now); }

    int constant ray = 10 ** 27;
    function add(int x, int y) internal pure returns (int z) {
        z = x + y;
        require(y <= 0 || z > x);
        require(y >= 0 || z < x);
    }
    function sub(int x, int y) internal pure returns (int z) {
        require(y != 2**255);
        z = add(x, y);
    }
    function mul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != 2**255);
        require(y == 0 || z / y == x);
    }
    function rmul(int x, int y) internal pure returns (int z) {
        z = add(mul(x, y), ray / 2) / ray;
    }

    constructor() public {
        root = msg.sender;
        live = true;
    }

    
    function form() public auth returns (bytes32 ilk) {
        ilk = bytes32(++forms);
        ilks[ilk].rate = ray;
        ilks[ilk].chop = ray;
    }
    function file(bytes32 what, uint risk) public auth {
        if (what == ) wait = uint48(risk);
        if (what == ) lump = int256(risk);
        if (what == ) line = int256(risk);
    }
    function file(bytes32 ilk, bytes32 what, uint risk) public auth {
        if (what == ) ilks[ilk].spot = int256(risk);
        if (what == ) ilks[ilk].rate = int256(risk);
        if (what == ) ilks[ilk].line = int256(risk);
        if (what == ) ilks[ilk].chop = int256(risk);
        if (what == ) wait = uint48(risk);
        if (what == ) lump = int256(risk);
        if (what == ) line = int256(risk);
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flippy(flip);
    }
    function flux(bytes32 ilk, address lad, int wad) public auth {
        urns[ilk][lad].gem = add(urns[ilk][lad].gem, wad);
    }

    
    function move(address src, address dst, uint256 wad) public auth {
        require(dai[src] >= int(wad));
        dai[src] = int(wad);
        dai[dst] += int(wad);
    }
    function burn(uint wad) public {
        require(wad <= uint(dai[msg.sender]));
        dai[msg.sender] = sub(dai[msg.sender], int(wad));
        tab = sub(tab, int(wad));
    }

    
    function frob(bytes32 ilk, int dink, int dart) public {
        urn storage u = urns[ilk][msg.sender];
        ilk storage i = ilks[ilk];

        u.gem = sub(u.gem, dink);
        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);
        tab   = add(  tab, rmul(i.rate, dart));
        dai[msg.sender] = add(dai[msg.sender], rmul(i.rate, dart));

        bool calm = rmul(i.art, i.rate) <= i.line && tab < line;
        bool cool = dart <= 0;
        bool firm = dink >= 0;
        bool safe = rmul(u.ink, i.spot) >= rmul(u.art, i.rate);

        require(( calm || cool ) && ( cool && firm || safe ) && live);
    }

    
    function drip(int wad) public auth {
        dai[this] = add(dai[this], wad);
        tab = add(tab, wad);
    }

    
    struct flip {
        bytes32 ilk;
        address lad;
        int256  ink;
        int256  tab;
    }
    flip[] public flips;

    function bite(bytes32 ilk, address lad) public returns (uint) {
        urn storage u = urns[ilk][lad];
        ilk storage i = ilks[ilk];

        int ink = u.ink;
        int art = u.art;
        int tab = rmul(art, i.rate);

        u.ink = 0;
        u.art = 0;
        i.art = sub(i.art, art);

        require(rmul(ink, i.spot) < tab);  

        sin[era()] = add(sin[era()], tab);
        return flips.push(flip(ilk, lad, ink, tab))  1;
    }
    mapping (uint48 => int) public sin;

    function grab(uint48 era_) public returns (uint tab) {
        require(era() >= era_ + wait);
        tab = uint(sin[era_]);
        sin[era_] = 0;
    }

    function flip(uint n, int wad) public returns (uint) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == lump || (wad < lump && wad == f.tab));

        int tab = f.tab;
        int ink = f.ink * wad / tab;

        f.tab = sub(f.tab, wad);
        f.ink = sub(f.ink, ink);

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: this
                                   , tab: uint(rmul(wad, i.chop))
                                   , lot: uint(ink)
                                   , bid: uint(0)
                                   });
    }
}
