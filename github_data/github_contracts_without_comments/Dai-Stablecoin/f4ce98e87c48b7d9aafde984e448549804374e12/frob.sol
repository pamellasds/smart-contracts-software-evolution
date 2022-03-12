

pragma solidity ^0.4.23;

contract gemlike {
    function move(address,address,uint) public;
}

contract flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
}

contract vat {
    address public root;
    bool    public live;
    uint256 public forms;

    address public flapper;
    address public flopper;

    uint256 public line;
    uint256 public lump;
    uint48  public wait;

    struct ilk {
        uint256  spot;  
        uint256  rate;  
        uint256  line;  
        uint256  chop;  

        uint256  art;   

        address  flip;
    }
    struct urn {
        uint256 gem;
        uint256 ink;
        uint256 art;
    }

    mapping (address => int256)                   public dai;
    mapping (bytes32 => ilk)                      public ilks;
    mapping (bytes32 => mapping (address => urn)) public urns;

    function gem(bytes32 ilk, address lad) public view returns (uint) {
        return urns[ilk][lad].gem;
    }
    function ink(bytes32 ilk, address lad) public view returns (uint) {
        return urns[ilk][lad].ink;
    }
    function art(bytes32 ilk, address lad) public view returns (uint) {
        return urns[ilk][lad].art;
    }
    uint public tab;

    function era() public view returns (uint48) { return uint48(now); }

    uint constant ray = 10 ** 27;
    uint constant maxint = uint(1) / 2;
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), ray / 2) / ray;
    }
    function rmuli(uint x, int y) internal pure returns (int z) {
        return y > 0 ? int(rmul(x, uint(y))) : int(rmul(x, uint(y)));
    }
    function addi(uint x, int y) internal pure returns (uint z) {
        z = uint(int(x) + y);  
    }
    function subi(uint x, int y) internal pure returns (uint z) {
        z = uint(int(x)  y);  
    }

    constructor() public {
        root = msg.sender;
        live = true;
    }

    
    function form() public returns (bytes32 ilk) {   
        ilk = bytes32(++forms);
        ilks[ilk].rate = ray;
        ilks[ilk].chop = ray;
    }
    function file(bytes32 what, uint risk) public {  
        if (what == ) wait = uint48(risk);
        if (what == ) lump = risk;
        if (what == ) line = risk;
    }
    function file(bytes32 ilk, bytes32 what, uint risk) public {  
        if (what == ) ilks[ilk].spot = risk;
        if (what == ) ilks[ilk].rate = risk;
        if (what == ) ilks[ilk].line = risk;
        if (what == ) ilks[ilk].chop = risk;
        if (what == ) wait = uint48(risk);
        if (what == ) lump = risk;
        if (what == ) line = risk;
    }
    function tiff(bytes32 ilk, address flip) public {       
        ilks[ilk].flip = flippy(flip);
    }
    function taff(address flap) public { flapper = flap; }  
    function toff(address flop) public { flopper = flop; }  

    function flux(bytes32 ilk, address lad, int wad) public {  
        urns[ilk][lad].gem = addi(urns[ilk][lad].gem, wad);
    }

    
    function move(address src, address dst, uint256 wad) public {  
        require(dai[src] >= int(wad));
        dai[src] = int(wad);
        dai[dst] += int(wad);
    }

    
    function frob(bytes32 ilk, int dink, int dart) public {
        urn storage u = urns[ilk][msg.sender];
        ilk storage i = ilks[ilk];

        u.gem = addi(u.gem, dink);
        u.ink = addi(u.ink,  dink);

        dai[msg.sender] += rmuli(i.rate, dart);
        u.art = addi(u.art, dart);
        i.art = addi(i.art, dart);
        tab   = addi(  tab, rmuli(i.rate, dart));

        bool calm = rmul(i.art, i.rate) <= i.line && tab < line;

        bool cool = dart <= 0;
        bool firm = dink >= 0;
        bool safe = rmul(u.ink, i.spot) >= rmul(u.art, i.rate);

        require(( calm || cool ) && ( cool && firm || safe ) && live);
    }

    
    function drip(int wad) public {  
        dai[this] += wad;
        tab = addi(tab, wad);
    }

    
    struct flip {
        bytes32 ilk;
        address lad;
        uint256 ink;
        uint256 tab;
    }
    flip[] public flips;
    mapping (uint48 => uint) public sin;

    function bite(bytes32 ilk, address lad) public returns (uint) {
        urn storage u = urns[ilk][lad];
        ilk storage i = ilks[ilk];

        uint ink = u.ink;
        uint art = u.art;
        uint tab = rmul(art, i.rate);

        u.ink = 0;
        u.art = 0;
        i.art = sub(i.art, art);

        require(rmul(ink, i.spot) < tab);  

        sin[era()] = add(sin[era()], tab);
        return flips.push(flip(ilk, lad, ink, tab))  1;
    }
    function flog(uint48 tic) public {
        require(tic + wait <= era());
        dai[this] = int(sin[tic]);
        tab = sub(tab, sin[tic]);
        sin[tic] = 0;
    }

    function flip(uint n, uint wad) public returns (uint) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == lump || (wad < lump && wad == f.tab));

        uint tab = f.tab;
        uint ink = f.ink * wad / tab;

        f.tab = sub(f.tab, wad);
        f.ink = sub(f.ink, ink);

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: this
                                   , tab: rmul(wad, i.chop)
                                   , lot: ink
                                   , bid: 0
                                   });
    }
    function flap() public returns (uint) {
        require(dai[this] >= int(lump));
        return fusspot(flapper).kick(this, lump, 0);
    }
    function flop() public returns (uint) {
        require(dai[this] <= int(lump));
        return fusspot(flopper).kick(this, uint(1), lump);
    }
}
