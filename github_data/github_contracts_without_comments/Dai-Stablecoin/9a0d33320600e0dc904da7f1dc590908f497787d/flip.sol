













pragma solidity >=0.5.0;

import ;

contract gemlike {
    function move(address,address,uint) public;
    function push(bytes32,uint) public;
}



contract flipper is dsnote {
    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        bytes32 urn;
        address gal;
        uint256 tab;
    }

    mapping (uint => bid) public bids;

    gemlike public   dai;
    gemlike public   gem;

    uint256 constant one = 1.00e27;
    uint256 public   beg = 1.05e27;  
    uint48  public   ttl = 3 hours;  
    uint48  public   tau = 2 days;   
    uint256 public kicks = 0;

    
    event kick(
      uint256 indexed id,
      uint256 lot,
      uint256 bid,
      address gal,
      uint48  end,
      bytes32 indexed urn,
      uint256 tab
    );

    
    constructor(address dai_, address gem_) public {
        dai = gemlike(dai_);
        gem = gemlike(gem_);
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        z = x + y;
        require(z >= x);
    }
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }

    
    function kick(bytes32 urn, address gal, uint tab, uint lot, uint bid)
        public returns (uint id)
    {
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = add(uint48(now), tau);
        bids[id].urn = urn;
        bids[id].gal = gal;
        bids[id].tab = tab;

        gem.move(msg.sender, address(this), lot);

        emit kick(id, lot, bid, gal, bids[id].end, bids[id].urn, bids[id].tab);
    }
    function tick(uint id) public note {
        require(bids[id].end < now);
        require(bids[id].tic == 0);
        bids[id].end = add(uint48(now), tau);
    }
    function tend(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(lot == bids[id].lot);
        require(bid <= bids[id].tab);
        require(bid >  bids[id].bid);
        require(mul(bid, one) >= mul(beg, bids[id].bid) || bid == bids[id].tab);

        dai.move(msg.sender, bids[id].guy, bids[id].bid);
        dai.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = add(uint48(now), ttl);
    }
    function dent(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(bid == bids[id].bid);
        require(bid == bids[id].tab);
        require(lot < bids[id].lot);
        require(mul(beg, lot) <= mul(bids[id].lot, one));

        dai.move(msg.sender, bids[id].guy, bid);
        gem.push(bids[id].urn, bids[id].lot  lot);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) public note {
        require(bids[id].tic != 0 && (bids[id].tic < now || bids[id].end < now));
        gem.push(bytes32(bytes20(bids[id].guy)), bids[id].lot);
        delete bids[id];
    }
}
