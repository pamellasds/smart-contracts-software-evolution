

pragma solidity ^0.4.24;

contract vat {
    function era() public view returns (uint48) { return uint48(now); }
    modifier auth { _; }  

    struct ilk {
        int256  rate;  
        int256  art;   
    }
    struct urn {
        int256 gem;
        int256 ink;
        int256 art;
    }

    mapping (address => int256)                   public dai;
    mapping (address => int256)                   public sin;
    mapping (bytes32 => ilk)                      public ilks;
    mapping (bytes32 => mapping (address => urn)) public urns;

    int256  public tab;
    int256  public vice;

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

    
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].rate = risk;
    }

    
    int256 constant one = 10 ** 27;
    function move(address src, address dst, uint wad) public auth {
        int rad = int(wad) * one;
        dai[src] = sub(dai[src], rad);
        dai[dst] = add(dai[dst], rad);
        require(dai[src] >= 0 && dai[dst] >= 0);
    }
    function slip(bytes32 ilk, address guy, int256 wad) public auth {
        urns[ilk][guy].gem = add(urns[ilk][guy].gem, wad);
    }

    
    function tune(bytes32 ilk, address lad, int dink, int dart) public auth {
        urn storage u = urns[ilk][lad];
        ilk storage i = ilks[ilk];

        u.gem = sub(u.gem, dink);
        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        dai[lad] = add(dai[lad], mul(i.rate, dart));
        tab      = add(tab,      mul(i.rate, dart));
    }

    
    function grab(bytes32 ilk, address lad, address vow, int dink, int dart) public auth {
        urn storage u = urns[ilk][lad];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        sin[vow] = sub(sin[vow], mul(i.rate, dart));
        vice     = sub(vice,     mul(i.rate, dart));
    }
    function heal(address u, address v, int wad) public auth {
        int rad = wad * one;

        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        tab    = sub(tab,    rad);

        require(sin[u] >= 0 && dai[v] >= 0);
        require(vice   >= 0 && tab    >= 0);
    }

    
    function fold(bytes32 ilk, address vow, int rate) public auth {
        ilk storage i = ilks[ilk];
        i.rate   = add(i.rate, rate);
        int wad  = mul(i.art, rate);
        dai[vow] = add(dai[vow], wad);
        tab      = add(tab, wad);
    }
}
