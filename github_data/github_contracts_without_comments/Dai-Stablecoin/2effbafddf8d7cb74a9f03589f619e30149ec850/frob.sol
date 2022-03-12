

pragma solidity ^0.4.23;

contract gemlike {
    function move(address,address,uint) public;
}

contract vat {
    address public root;
    bool    public live;
    uint256 public forms;
    int256  public line;
    int256  public vice;

    modifier auth {
        
        _;
    }

    struct ilk {
        int256  spot;  
        int256  rate;  
        int256  line;  
        int256  art;   
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
    }
    function file(bytes32 what, uint risk) public auth {
        if (what == ) line = int256(risk);
    }
    function file(bytes32 ilk, bytes32 what, uint risk) public auth {
        if (what == ) ilks[ilk].spot = int256(risk);
        if (what == ) ilks[ilk].rate = int256(risk);
        if (what == ) ilks[ilk].line = int256(risk);
    }

    
    function move(address src, address dst, uint256 wad) public auth {
        require(dai[src] >= int(wad));
        dai[src] = int(wad);
        dai[dst] += int(wad);
    }
    function slip(bytes32 ilk, address guy, int256 wad) public auth {
        urns[ilk][guy].gem = add(urns[ilk][guy].gem, wad);
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

    
    function fold(bytes32 ilk, address vow, int rate) public auth {
        ilk storage i = ilks[ilk];
        i.rate   = add(i.rate, rate);
        int wad  = rmul(i.art, rate);
        dai[vow] = add(dai[vow], wad);
        tab      = add(tab, wad);
    }

    
    function grab(bytes32 ilk, address lad, address vow, int dink, int dart) public auth {
        urn storage u = urns[ilk][lad];
        urn storage v = urns[ilk][vow];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        v.gem = sub(v.gem, dink);

        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        vice = sub(vice, rmul(i.rate, dart));
    }
    function heal(address vow, int wad) public auth {
        dai[vow] = sub(dai[vow], wad);
        vice = sub(vice, wad);
    }
}
