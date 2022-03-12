













pragma solidity ^0.4.24;

contract pielike {
    function move(bytes32,bytes32,int)  public;
}

contract gemlike {
    function move(address,address,uint) public;
}




contract flapper {
    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address gal;
    }

    mapping (uint => bid) public bids;

    pielike  public   pie;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 1 weeks;  

    uint256  public   kicks;

    function era() public view returns (uint48) { return uint48(now); }

    
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }

    
    constructor(address pie_, address gem_) public {
        pie = pielike(pie_);
        gem = gemlike(gem_);
    }

    
    function kick(address gal, uint lot, uint bid)
        public returns (uint)
    {
        uint id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = era() + tau;
        bids[id].gal = gal;

        pie.move(bytes32(msg.sender), bytes32(address(this)), mul(lot, one));

        return id;
    }
    function tend(uint id, uint lot, uint bid) public {
        require(bids[id].guy != 0);
        require(bids[id].tic > era() || bids[id].tic == 0);
        require(bids[id].end > era());

        require(lot == bids[id].lot);
        require(bid >  bids[id].bid);
        require(mul(bid, one) >= mul(beg, bids[id].bid));

        gem.move(msg.sender, bids[id].guy, bids[id].bid);
        gem.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = era() + ttl;
    }
    function deal(uint id) public {
        require(bids[id].tic < era() && bids[id].tic != 0 ||
                bids[id].end < era());
        pie.move(bytes32(address(this)), bytes32(bids[id].guy), mul(bids[id].lot, one));
        delete bids[id];
    }
}
