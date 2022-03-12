













pragma solidity ^0.4.24;

contract vat {
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

    mapping (bytes32 => int256)                   public dai;  
    mapping (bytes32 => int256)                   public sin;  
    mapping (bytes32 => ilk)                      public ilks;
    mapping (bytes32 => mapping (bytes32 => urn)) public urns;

    function dai(address guy) public view returns (int) {
        return dai[bytes32(guy)];
    }
    function urns(bytes32 ilk, address lad) public view returns (int,int,int) {
        urn storage u = urns[ilk][bytes32(lad)];
        return (u.gem, u.ink, u.art);
    }

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
        require(int(wad) >= 0);
        move(src, dst, int(wad));
    }
    function move(address src_, address dst_, int wad) public auth {
        bytes32 src = bytes32(src_);
        bytes32 dst = bytes32(dst_);
        int rad = mul(wad, one);
        dai[src] = sub(dai[src], rad);
        dai[dst] = add(dai[dst], rad);
        require(dai[src] >= 0 && dai[dst] >= 0);
    }
    function slip(bytes32 ilk, address guy_, int256 wad) public auth {
        bytes32 guy = bytes32(guy_);
        urns[ilk][guy].gem = add(urns[ilk][guy].gem, wad);
        require(urns[ilk][guy].gem >= 0);
    }
    function flux(bytes32 ilk, address src_, address dst_, int256 wad) public auth {
        bytes32 src = bytes32(src_);
        bytes32 dst = bytes32(dst_);
        urns[ilk][src].gem = sub(urns[ilk][src].gem, wad);
        urns[ilk][dst].gem = add(urns[ilk][dst].gem, wad);
        require(urns[ilk][src].gem >= 0 && urns[ilk][dst].gem >= 0);
    }

    
    function tune(bytes32 ilk, address u_, address v_, address w_, int dink, int dart) public auth {
        urn storage u = urns[ilk][bytes32(u_)];
        urn storage v = urns[ilk][bytes32(v_)];
        ilk storage i = ilks[ilk];

        v.gem = sub(v.gem, dink);
        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        dai[bytes32(w_)] = add(dai[bytes32(w_)], mul(i.rate, dart));
        tab     = add(tab,     mul(i.rate, dart));
    }

    
    function grab(bytes32 ilk, address u_, address v_, address w_, int dink, int dart) public auth {
        urn storage u = urns[ilk][bytes32(u_)];
        urn storage v = urns[ilk][bytes32(v_)];
        ilk storage i = ilks[ilk];

        v.gem = sub(v.gem, dink);
        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        sin[bytes32(w_)] = sub(sin[bytes32(w_)], mul(i.rate, dart));
        vice    = sub(vice,    mul(i.rate, dart));
    }
    function heal(address u_, address v_, int wad) public auth {
        bytes32 u = bytes32(u_);
        bytes32 v = bytes32(v_);
        int rad = mul(wad, one);

        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        tab    = sub(tab,    rad);

        require(sin[u] >= 0 && dai[v] >= 0);
        require(vice   >= 0 && tab    >= 0);
    }

    
    function fold(bytes32 ilk, address vow_, int rate) public auth {
        bytes32 vow = bytes32(vow_);
        ilk storage i = ilks[ilk];
        i.rate   = add(i.rate, rate);
        int rad  = mul(i.art, rate);
        dai[vow] = add(dai[vow], rad);
        tab      = add(tab, rad);
    }
}
