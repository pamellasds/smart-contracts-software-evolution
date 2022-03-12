













pragma solidity ^0.4.24;

contract vat {
    modifier auth { _; }  

    struct ilk {
        uint256  rate;  
        uint256  art;   
    }
    struct urn {
        uint256 ink;    
        uint256 art;    
    }

    mapping (bytes32 => ilk)                       public ilks;
    mapping (bytes32 => mapping (bytes32 => urn )) public urns;
    mapping (bytes32 => mapping (bytes32 => uint)) public gem;    
    mapping (bytes32 => uint256)                   public dai;    
    mapping (bytes32 => uint256)                   public sin;    

    uint256  public debt;  
    uint256  public vice;  

    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y <= 0 || z > x);
        require(y >= 0 || z < x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = add(x, y);
        require(y != 2**255);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }

    
    function init(bytes32 ilk) public auth {
        require(ilks[ilk].rate == 0);
        ilks[ilk].rate = 10 ** 27;
    }

    
    function move(bytes32 src, bytes32 dst, uint256 rad) public auth {
        require(int(rad) >= 0);
        dai[src] = sub(dai[src], int(rad));
        dai[dst] = add(dai[dst], int(rad));
    }
    function slip(bytes32 ilk, bytes32 guy, int256 wad) public auth {
        gem[ilk][guy] = add(gem[ilk][guy], wad);
    }
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad) public auth {
        gem[ilk][src] = sub(gem[ilk][src], wad);
        gem[ilk][dst] = add(gem[ilk][dst], wad);
    }

    
    function tune(bytes32 ilk, bytes32 u_, bytes32 v, bytes32 w, int dink, int dart) public auth {
        urn storage u = urns[ilk][u_];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        gem[ilk][v] = sub(gem[ilk][v], dink);
        dai[w]      = add(dai[w],      mul(i.rate, dart));
        debt        = add(debt,        mul(i.rate, dart));
    }

    
    function grab(bytes32 ilk, bytes32 u_, bytes32 v, bytes32 w, int dink, int dart) public auth {
        urn storage u = urns[ilk][u_];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        gem[ilk][v] = sub(gem[ilk][v], dink);
        sin[w]      = sub(sin[w],      mul(i.rate, dart));
        vice        = sub(vice,        mul(i.rate, dart));
    }
    function heal(bytes32 u, bytes32 v, int rad) public auth {
        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        debt   = sub(debt,   rad);
    }

    
    function fold(bytes32 ilk, bytes32 guy, int rate) public auth {
        ilk storage i = ilks[ilk];
        int rad  = mul(i.art, rate);
        dai[guy] = add(dai[guy], rad);
        debt     = add(debt,     rad);
        i.rate   = add(i.rate, rate);
    }
}
