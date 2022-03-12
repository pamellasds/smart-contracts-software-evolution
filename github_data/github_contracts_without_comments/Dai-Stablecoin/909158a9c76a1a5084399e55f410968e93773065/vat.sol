













pragma solidity >=0.5.0;

contract vat {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    mapping(address => mapping (address => uint)) public can;
    function hope(address usr) public { can[msg.sender][usr] = 1; }
    function nope(address usr) public { can[msg.sender][usr] = 0; }
    function wish(address bit, address usr) internal view returns (bool) {
        return bit == usr || can[bit][usr] == 1;
    }

    
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

    mapping (bytes32 => ilk)                       public ilks;
    mapping (bytes32 => mapping (address => urn )) public urns;
    mapping (bytes32 => mapping (address => uint)) public gem;  
    mapping (address => uint256)                   public dai;  
    mapping (address => uint256)                   public sin;  

    uint256 public debt;  
    uint256 public vice;  
    uint256 public line;  
    uint256 public live;  

    
    event lognote(
        bytes4   indexed  sig,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes32  indexed  arg3,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
            
            
            let mark := msize                         
            mstore(0x40, add(mark, 288))              
            mstore(mark, 0x20)                        
            mstore(add(mark, 0x20), 224)              
            calldatacopy(add(mark, 0x40), 0, 224)     
            log4(mark, 288,                           
                 shl(224, shr(224, calldataload(0))), 
                 calldataload(4),                     
                 calldataload(36),                    
                 calldataload(68)                     
                )
        }
    }

    
    constructor() public {
        wards[msg.sender] = 1;
        live = 1;
    }

    
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x  uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function init(bytes32 ilk) public note auth {
        require(ilks[ilk].rate == 0);
        ilks[ilk].rate = 10 ** 27;
    }
    function file(bytes32 what, uint data) public note auth {
        if (what == ) line = data;
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].spot = data;
        if (what == ) ilks[ilk].line = data;
        if (what == ) ilks[ilk].dust = data;
    }
    function cage() public note auth {
        live = 0;
    }

    
    function slip(bytes32 ilk, address usr, int256 wad) public note auth {
        gem[ilk][usr] = add(gem[ilk][usr], wad);
    }
    function flux(bytes32 ilk, address src, address dst, uint256 wad) public note {
        require(wish(src, msg.sender));
        gem[ilk][src] = sub(gem[ilk][src], wad);
        gem[ilk][dst] = add(gem[ilk][dst], wad);
    }
    function move(address src, address dst, uint256 rad) public note {
        require(wish(src, msg.sender));
        dai[src] = sub(dai[src], rad);
        dai[dst] = add(dai[dst], rad);
    }

    
    function frob(bytes32 i, address u, address v, address w, int dink, int dart) public note {
        urn memory urn = urns[i][u];
        ilk memory ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        int dtab = mul(ilk.rate, dart);
        uint tab = mul(urn.art, ilk.rate);

        gem[i][v] = sub(gem[i][v], dink);
        dai[w]    = add(dai[w],    dtab);
        debt      = add(debt,      dtab);

        
        require(dart <= 0 || mul(ilk.art, ilk.rate) <= ilk.line && debt <= line);
        
        require(dart <= 0 && dink >= 0 || tab <= mul(urn.ink, ilk.spot));

        
        require(dart <= 0 && dink >= 0 || wish(u, msg.sender));
        
        require(dink <= 0 || wish(v, msg.sender));
        
        require(dart >= 0 || wish(w, msg.sender));

        
        require(urn.art == 0 || tab >= ilk.dust);
        
        require(ilk.rate != 0);
        
        require(live == 1);

        urns[i][u] = urn;
        ilks[i]    = ilk;
    }
    
    function fork(bytes32 ilk, address src, address dst, int dink, int dart) public note {
        urn storage u = urns[ilk][src];
        urn storage v = urns[ilk][dst];
        ilk storage i = ilks[ilk];

        u.ink = sub(u.ink, dink);
        u.art = sub(u.art, dart);
        v.ink = add(v.ink, dink);
        v.art = add(v.art, dart);

        uint utab = mul(u.art, i.rate);
        uint vtab = mul(v.art, i.rate);

        
        require(wish(src, msg.sender) && wish(dst, msg.sender));

        
        require(utab <= mul(u.ink, i.spot));
        require(vtab <= mul(v.ink, i.spot));

        
        require(utab >= i.dust || u.art == 0);
        require(vtab >= i.dust || v.art == 0);
    }
    
    function grab(bytes32 i, address u, address v, address w, int dink, int dart) public note auth {
        urn storage urn = urns[i][u];
        ilk storage ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        int dtab = mul(ilk.rate, dart);

        gem[i][v] = sub(gem[i][v], dink);
        sin[w]    = sub(sin[w],    dtab);
        vice      = sub(vice,      dtab);
    }

    
    function heal(uint rad) public note {
        address u = msg.sender;
        sin[u] = sub(sin[u], rad);
        dai[u] = sub(dai[u], rad);
        vice   = sub(vice,   rad);
        debt   = sub(debt,   rad);
    }
    function suck(address u, address v, uint rad) public note auth {
        sin[u] = add(sin[u], rad);
        dai[v] = add(dai[v], rad);
        vice   = add(vice,   rad);
        debt   = add(debt,   rad);
    }

    
    function fold(bytes32 i, address u, int rate) public note auth {
        require(live == 1);
        ilk storage ilk = ilks[i];
        ilk.rate = add(ilk.rate, rate);
        int rad  = mul(ilk.art, rate);
        dai[u]   = add(dai[u], rad);
        debt     = add(debt,   rad);
    }
}
