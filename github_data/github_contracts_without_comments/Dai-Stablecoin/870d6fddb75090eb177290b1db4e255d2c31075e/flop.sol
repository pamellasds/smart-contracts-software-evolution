













pragma solidity 0.5.12;

import ;

contract vatlike {
    function move(address,address,uint) external;
    function suck(address,address,uint) external;
}
contract gemlike {
    function mint(address,uint) external;
}



contract flopper is libnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) external note auth { wards[usr] = 1; }
    function deny(address usr) external note auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, );
        _;
    }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
    }

    mapping (uint => bid) public bids;

    vatlike  public   vat;
    gemlike  public   gem;

    uint256  constant one = 1.00e18;
    uint256  public   beg = 1.05e18;  
    uint256  public   pad = 1.50e18;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 2 days;   
    uint256  public kicks = 0;
    uint256  public live;
    address  public vow;  

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      address indexed gal
    );

    
    constructor(address vat_, address gem_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        gem = gemlike(gem_);
        live = 1;
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        require((z = x + y) >= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint data) external note auth {
        if (what == ) beg = data;
        else if (what == ) pad = data;
        else if (what == ) ttl = uint48(data);
        else if (what == ) tau = uint48(data);
        else revert();
    }

    
    function kick(address gal, uint lot, uint bid) external auth returns (uint id) {
        require(live == 1, );
        require(kicks < uint(1), );
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = gal;
        bids[id].end = add(uint48(now), tau);

        emit kick(id, lot, bid, gal);
    }
    function tick(uint id) external note {
        require(bids[id].end < now, );
        require(bids[id].tic == 0, );
        bids[id].lot = mul(pad, bids[id].lot) / one;
        bids[id].end = add(uint48(now), tau);
    }
    function dent(uint id, uint lot, uint bid) external note {
        require(live == 1, );
        require(bids[id].guy != address(0), );
        require(bids[id].tic > now || bids[id].tic == 0, );
        require(bids[id].end > now, );

        require(bid == bids[id].bid, );
        require(lot <  bids[id].lot, );
        require(mul(beg, lot) <= mul(bids[id].lot, one), );

        vat.move(msg.sender, bids[id].guy, bid);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) external note {
        require(live == 1, );
        require(bids[id].tic != 0 && (bids[id].tic < now || bids[id].end < now), );
        gem.mint(bids[id].guy, bids[id].lot);
        delete bids[id];
    }

    
    function cage() external note auth {
       live = 0;
       vow = msg.sender;
    }
    function yank(uint id) external note {
        require(live == 0, );
        require(bids[id].guy != address(0), );
        vat.suck(vow, bids[id].guy, bids[id].bid);
        delete bids[id];
    }
}
