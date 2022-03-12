













pragma solidity >=0.5.0;

contract vat {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    mapping(address => mapping (address => uint)) public can;
    function hope(address guy) public { can[msg.sender][guy] = 1; }
    function nope(address guy) public { can[msg.sender][guy] = 0; }
    function wish(bytes32 bit, address usr) internal view returns (bool) {
        return address(bytes20(bit)) == usr || can[address(bytes20(bit))][usr] == 1;
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
    mapping (bytes32 => mapping (bytes32 => urn )) public urns;
    mapping (bytes32 => mapping (bytes32 => uint)) public gem;  
    mapping (bytes32 => uint256)                   public dai;  
    mapping (bytes32 => uint256)                   public sin;  

    uint256 public debt;  
    uint256 public vice;  
    uint256 public line;  
    uint256 public live;  

    
    event note(
        bytes4   indexed  hash,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes32  indexed  arg3,
        bytes             data
    ) anonymous;
    modifier note {
        bytes32 arg1;
        bytes32 arg2;
        bytes32 arg3;
        assembly {
            arg1 := calldataload(4)
            arg2 := calldataload(36)
            arg3 := calldataload(68)
        }
        emit note(msg.sig, arg1, arg2, arg3, msg.data); _;
    }

    
    constructor() public {
        wards[msg.sender] = 1;
        live = 1;
    }

    
    function add(uint x, int y) internal pure returns (uint z) {
      assembly {
        z := add(x, y)
        if sgt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        if slt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    function sub(uint x, int y) internal pure returns (uint z) {
      assembly {
        z := sub(x, y)
        if slt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        if sgt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    function mul(uint x, int y) internal pure returns (int z) {
      assembly {
        z := mul(x, y)
        if slt(x, 0) { revert(0, 0) }
        if iszero(eq(y, 0)) { if iszero(eq(sdiv(z, y), x)) { revert(0, 0) } }
      }
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

    
    function slip(bytes32 ilk, bytes32 guy, int256 rad) public note auth {
        gem[ilk][guy] = add(gem[ilk][guy], rad);
    }
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 rad) public note auth {
        gem[ilk][src] = sub(gem[ilk][src], rad);
        gem[ilk][dst] = add(gem[ilk][dst], rad);
    }
    function move(bytes32 src, bytes32 dst, int256 rad) public note auth {
        dai[src] = sub(dai[src], rad);
        dai[dst] = add(dai[dst], rad);
    }

    
    function frob(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note {
        urn storage urn = urns[i][u];
        ilk storage ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        gem[i][v] = sub(gem[i][v], dink);
        dai[w]    = add(dai[w], mul(ilk.rate, dart));
        debt      = add(debt,   mul(ilk.rate, dart));

        bool cool = dart <= 0;
        bool firm = dink >= 0;
        bool nice = cool && firm;
        bool calm = mul(ilk.art, ilk.rate) <= ilk.line && debt <= line;
        bool safe = mul(urn.art, ilk.rate) <= mul(urn.ink, ilk.spot);

        require((calm || cool) && (nice || safe));

        require(wish(u, msg.sender) ||  nice);
        require(wish(v, msg.sender) || !firm);
        require(wish(w, msg.sender) || !cool);

        require(mul(urn.art, ilk.rate) >= ilk.dust || urn.art == 0);
        require(ilk.rate != 0);
        require(live == 1);
    }
    
    function fork(bytes32 ilk, bytes32 src, bytes32 dst, int dink, int dart) public note {
        urn storage u = urns[ilk][src];
        urn storage v = urns[ilk][dst];
        ilk storage i = ilks[ilk];

        u.ink = sub(u.ink, dink);
        u.art = sub(u.art, dart);
        v.ink = add(v.ink, dink);
        v.art = add(v.art, dart);

        
        require(wish(src, msg.sender) && wish(dst, msg.sender));

        
        require(mul(u.art, i.rate) <= mul(u.ink, i.spot));
        require(mul(v.art, i.rate) <= mul(v.ink, i.spot));

        
        require(mul(u.art, i.rate) >= i.dust || u.art == 0);
        require(mul(v.art, i.rate) >= i.dust || v.art == 0);
    }
    
    function grab(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note auth {
        urn storage urn = urns[i][u];
        ilk storage ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        gem[i][v] = sub(gem[i][v], dink);
        sin[w]    = sub(sin[w], mul(ilk.rate, dart));
        vice      = sub(vice,   mul(ilk.rate, dart));
    }

    
    function heal(bytes32 u, bytes32 v, int rad) public note auth {
        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        debt   = sub(debt,   rad);
    }

    
    function fold(bytes32 i, bytes32 u, int rate) public note auth {
        ilk storage ilk = ilks[i];
        ilk.rate = add(ilk.rate, rate);
        int rad  = mul(ilk.art, rate);
        dai[u]   = add(dai[u], rad);
        debt     = add(debt,   rad);
    }
}
