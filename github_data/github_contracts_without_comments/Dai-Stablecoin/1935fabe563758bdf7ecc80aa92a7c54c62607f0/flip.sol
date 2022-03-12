













pragma solidity ^0.4.24;

contract vatlike {
    function move(bytes32,bytes32,uint)         public;
    function flux(bytes32,bytes32,bytes32,int)  public;
}




contract flipper {
    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        bytes32 lad;
        address gal;
        uint256 tab;
    }

    mapping (uint => bid) public bids;

    vatlike public   vat;
    bytes32 public   ilk;

    uint256 constant one = 1.00e27;
    uint256 public   beg = 1.05e27;  
    uint48  public   ttl = 3 hours;  
    uint48  public   tau = 1 weeks;  

    uint256 public   kicks;

    function era() public view returns (uint48) { return uint48(now); }

    
    constructor(address vat_, bytes32 ilk_) public {
        ilk = ilk_;
        vat = vatlike(vat_);
    }

    
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function kick(bytes32 lad, address gal, uint tab, uint lot, uint bid)
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

        vat.flux(ilk, bytes32(msg.sender), bytes32(address(this)), int(lot));

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

        vat.move(bytes32(msg.sender), bytes32(bids[id].guy), mul(bids[id].bid, one));
        vat.move(bytes32(msg.sender), bytes32(bids[id].gal), mul(bid  bids[id].bid, one));

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

        vat.move(bytes32(msg.sender), bytes32(bids[id].guy), mul(bid, one));
        vat.flux(ilk, bytes32(address(this)), bids[id].lad, int(bids[id].lot  lot));

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = era() + ttl;
    }
    function deal(uint id) public {
        require(bids[id].tic < era() && bids[id].tic != 0 ||
                bids[id].end < era());
        vat.flux(ilk, bytes32(address(this)), bytes32(bids[id].guy), int(bids[id].lot));
        delete bids[id];
    }
}
