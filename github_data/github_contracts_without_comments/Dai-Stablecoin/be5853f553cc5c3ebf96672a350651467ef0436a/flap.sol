

pragma solidity ^0.4.24;

contract gemlike {
    function move(address,address,uint) public;
}




contract flapper {
    gemlike public pie;
    gemlike public gem;

    uint256 public beg = 1.05 ether;  
    uint48  public ttl = 3.00 hours;  
    uint48  public tau = 1 weeks;     

    uint256 public kicks;

    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address gal;
    }

    mapping (uint => bid) public bids;

    function era() public view returns (uint48) { return uint48(now); }

    uint constant wad = 10 ** 18;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require((y == 0 || x * y / y == x) && (z = x * y + wad / 2) >= x * y);
        z = z / wad;
    }

    constructor(address pie_, address gem_) public {
        pie = gemlike(pie_);
        gem = gemlike(gem_);
    }

    function kick(address gal, uint lot, uint bid)
        public returns (uint)
    {
        uint id = ++kicks;
        pie.move(msg.sender, this, lot);

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = era() + tau;
        bids[id].gal = gal;

        return id;
    }
    function tend(uint id, uint lot, uint bid) public {
        require(bids[id].guy != 0);
        require(bids[id].tic > era() || bids[id].tic == 0);
        require(bids[id].end > era());

        require(lot == bids[id].lot);
        require(bid >  bids[id].bid);
        require(bid >= mul(beg, bids[id].bid));

        gem.move(msg.sender, bids[id].guy, bids[id].bid);
        gem.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = era() + ttl;
    }
    function deal(uint id) public {
        require(bids[id].tic < era() && bids[id].tic != 0 ||
                bids[id].end < era());
        pie.move(this, bids[id].guy, bids[id].lot);
        delete bids[id];
    }
}
