













pragma solidity >=0.5.0;

import ;

contract dailike {
    function move(address,address,uint) public;
}
contract gemlike {
    function move(address,address,uint) public;
}



contract flapper is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address gal;
    }

    mapping (uint => bid) public bids;

    dailike  public   dai;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 2 days;   
    uint256  public kicks = 0;
    uint256  public live;

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      address indexed gal
    );

    
    constructor(address dai_, address gem_) public {
        wards[msg.sender] = 1;
        dai = dailike(dai_);
        gem = gemlike(gem_);
        live = 1;
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        require((z = x + y) >= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) beg = data;
        if (what == ) ttl = uint48(data);
        if (what == ) tau = uint48(data);
    }

    
    function kick(address gal, uint lot, uint bid)
        public returns (uint id)
    {
        require(live == 1);
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = add(uint48(now), tau);
        bids[id].gal = gal;

        dai.move(msg.sender, address(this), lot);

        emit kick(id, lot, bid, gal);
    }
    function tend(uint id, uint lot, uint bid) public note {
        require(live == 1);
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(lot == bids[id].lot);
        require(bid >  bids[id].bid);
        require(mul(bid, one) >= mul(beg, bids[id].bid));

        gem.move(msg.sender, bids[id].guy, bids[id].bid);
        gem.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) public note {
        require(live == 1);
        require(bids[id].tic < now && bids[id].tic != 0 ||
                bids[id].end < now);
        dai.move(address(this), bids[id].guy, bids[id].lot);
        delete bids[id];
    }

    function cage(uint rad) public note auth {
       live = 0;
       dai.move(address(this), msg.sender, rad);
    }
    function yank(uint id) public note {
        require(live == 0);
        require(bids[id].guy != address(0));
        gem.move(address(this), bids[id].guy, bids[id].bid);
        delete bids[id];
    }
}
