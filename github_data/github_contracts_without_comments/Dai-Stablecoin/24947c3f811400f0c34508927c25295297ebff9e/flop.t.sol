pragma solidity >=0.5.0;

import {dstest}  from ;
import {dstoken} from ;
import ;
import ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flopper flop;
    constructor(flopper flop_) public {
        flop = flop_;
        vat(address(flop.vat())).hope(address(flop));
        dstoken(address(flop.gem())).approve(address(flop));
    }
    function dent(uint id, uint lot, uint bid) public {
        flop.dent(id, lot, bid);
    }
    function deal(uint id) public {
        flop.deal(id);
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id));
    }
    function try_tick(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(flop).call(abi.encodewithsignature(sig, id));
    }
}

contract gal {}

contract vatish is dstoken() {
    uint constant one = 10 ** 27;
    function move(address src, address dst, uint rad) public {
        super.move(src, dst, rad);
    }
    function hope(address usr) public {
         super.approve(usr);
    }
    function dai(address usr) public returns (uint) {
         return super.balanceof(usr);
    }
}

contract floptest is dstest {
    hevm hevm;

    flopper flop;
    vat     vat;
    dstoken gem;

    address ali;
    address bob;
    address gal;

    function kiss(uint) public pure { }  

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        gem = new dstoken();

        flop = new flopper(address(vat), address(gem));

        ali = address(new guy(flop));
        bob = address(new guy(flop));
        gal = address(new gal());

        vat.hope(address(flop));
        gem.approve(address(flop));

        vat.suck(address(this), address(this), 1000 ether);

        vat.move(address(this), ali, 200 ether);
        vat.move(address(this), bob, 200 ether);
    }
    function test_kick() public {
        asserteq(vat.dai(address(this)), 600 ether);
        asserteq(gem.balanceof(address(this)),   0 ether);
        flop.kick({ lot: 200 ether   
                  , gal: gal
                  , bid: 0
                  });
        
        asserteq(vat.dai(address(this)), 600 ether);
        asserteq(gem.balanceof(address(this)),   0 ether);
    }
    function test_dent() public {
        uint id = flop.kick({ lot: 200 ether   
                            , gal: gal
                            , bid: 10 ether
                            });

        guy(ali).dent(id, 100 ether, 10 ether);
        
        asserteq(vat.dai(ali), 190 ether);
        
        asserteq(vat.dai(gal),  10 ether);

        guy(bob).dent(id, 80 ether, 10 ether);
        
        asserteq(vat.dai(bob), 190 ether);
        
        asserteq(vat.dai(ali), 200 ether);
        
        asserteq(vat.dai(gal), 10 ether);

        hevm.warp(now + 5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(address(flop));
        guy(bob).deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }
    function test_tick() public {
        
        uint id = flop.kick({ lot: 200 ether   
                            , gal: gal
                            , bid: 10 ether
                            });
        
        asserttrue(!guy(ali).try_tick(id));
        
        hevm.warp(now + 2 weeks);
        
        asserttrue(!guy(ali).try_dent(id, 100 ether, 10 ether));
        asserttrue( guy(ali).try_tick(id));
        
        (, uint _lot,,,) = flop.bids(id);
        
        asserteq(_lot, 300 ether);
        asserttrue( guy(ali).try_dent(id, 100 ether, 10 ether));
    }
    function test_no_deal_after_end() public {
        
        
        uint id = flop.kick({ lot: 200 ether   
                            , gal: gal
                            , bid: 10 ether
                            });
        asserttrue(!guy(ali).try_deal(id));
        hevm.warp(now + 2 weeks);
        asserttrue(!guy(ali).try_deal(id));
        asserttrue( guy(ali).try_tick(id));
        asserttrue(!guy(ali).try_deal(id));
    }
}
