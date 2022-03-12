















pragma solidity ^0.4.24;

contract pielike {
    function move(bytes32,bytes32,uint) public;
}

contract gemlike {
    function mint(address,uint) public;
}



contract flopper {
    pielike  public   pie;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 1 weeks;  

    uint256  public   kicks;

    modifier auth { _; }  

    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address vow;
    }

    mapping (uint => bid) public bids;

    function era() public view returns (uint48) { return uint48(now); }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    constructor(address pie_, address gem_) public {
        pie = pielike(pie_);
        gem = gemlike(gem_);
    }

    function kick(address gal, uint lot, uint bid) public auth returns (uint) {
        uint id = ++kicks;

        bids[id].vow = msg.sender;
        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = gal;
        bids[id].end = era() + tau;

        return id;
    }
    function dent(uint id, uint lot, uint bid) public {
        require(bids[id].guy != 0);
        require(bids[id].tic > era() || bids[id].tic == 0);
        require(bids[id].end > era());

        require(bid == bids[id].bid);
        require(lot <  bids[id].lot);
        require(mul(beg, lot) / one <= bids[id].lot);  

        pie.move(bytes32(msg.sender), bytes32(bids[id].guy), mul(bid, one));

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = era() + ttl;
    }
    function deal(uint id) public {
        require(bids[id].tic < era() && bids[id].tic != 0 ||
                bids[id].end < era());
        gem.mint(bids[id].guy, bids[id].lot);
        delete bids[id];
    }
}
