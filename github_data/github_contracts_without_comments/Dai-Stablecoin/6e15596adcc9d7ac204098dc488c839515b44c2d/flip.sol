

pragma solidity ^0.4.24;

contract gemlike {
    function move(address,address,uint) public;
}

contract vatlike {
    function move(address,address,uint) public;
    function slip(bytes32,address,int)  public;
}




contract flipper {
    vatlike public vat;
    bytes32 public ilk;

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
        address lad;
        address gal;
        uint256 tab;
    }

    mapping (uint => bid) public bids;

    function era() public view returns (uint48) { return uint48(now); }

    uint constant one = 10 ** 18;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    constructor(address vat_, bytes32 ilk_) public {
        ilk = ilk_;
        vat = vatlike(vat_);
    }

    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint)
    {
        uint id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = msg.sender; 
        bids[id].end = era() + tau;
        bids[id].lad = lad;
        bids[id].gal = gal;
        bids[id].tab = tab;

        return id;
    }
    function tick(uint id) public {
        require(bids[id].end < era());
        require(bids[id].tic == 0);
        bids[id].end = era() + tau;
    }
    function tend(uint id, uint lot, uint bid) public {
        require(bids[id].guy != 0);
        require(bids[id].tic > era() || bids[id].tic == 0);
        require(bids[id].end > era());

        require(lot == bids[id].lot);
        require(bid <= bids[id].tab);
        require(bid >  bids[id].bid);
        require(mul(bid, one) >= mul(beg, bids[id].bid) || bid == bids[id].tab);

        vat.move(msg.sender, bids[id].guy, bids[id].bid);
        vat.move(msg.sender, bids[id].gal, bid  bids[id].bid);

        bids[id].guy = msg.sender;
        bids[id].bid = bid;
        bids[id].tic = era() + ttl;
    }
    function dent(uint id, uint lot, uint bid) public {
        require(bids[id].guy != 0);
        require(bids[id].tic > era() || bids[id].tic == 0);
        require(bids[id].end > era());

        require(bid == bids[id].bid);
        require(bid == bids[id].tab);
        require(lot < bids[id].lot);
        require(mul(beg, lot) <= mul(bids[id].lot, one));

        vat.move(msg.sender, bids[id].guy, bid);
        vat.slip(ilk, bids[id].lad, int(bids[id].lot  lot));

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = era() + ttl;
    }
    function deal(uint id) public {
        require(bids[id].tic < era() && bids[id].tic != 0 ||
                bids[id].end < era());
        vat.slip(ilk, bids[id].guy, int(bids[id].lot));
        delete bids[id];
    }
}
