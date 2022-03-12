













pragma solidity ^0.4.24;

import ;

contract gemlike {
    function move(address,address,uint) public;
}



contract flapper is dsnote {
    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address gal;
    }

    mapping (uint => bid) public bids;

    gemlike  public   dai;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 2 days;   
    uint256  public kicks = 0;

    
    event kick(
      uint256 indexed id,
      uint256 lot,
      uint256 bid,
      address gal,
      uint48  end
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

    
    function kick(address gal, uint lot, uint bid)
        public returns (uint id)
    {
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = add(uint48(now), tau);
        bids[id].gal = gal;

        dai.move(msg.sender, this, lot);

        emit kick(id, lot, bid, gal, bids[id].end);
    }
    function tend(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != 0);
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
        require(bids[id].tic < now && bids[id].tic != 0 ||
                bids[id].end < now);
        dai.move(this, bids[id].guy, bids[id].lot);
        delete bids[id];
    }
}
