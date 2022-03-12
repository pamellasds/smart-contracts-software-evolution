pragma solidity >=0.5.0;

import ;
import {dstoken} from ;
import ;
import ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flapper fuss;
    constructor(flapper fuss_) public {
        fuss = fuss_;
        vat(address(fuss.vat())).hope(address(fuss));
        dstoken(address(fuss.gem())).approve(address(fuss));
    }
    function tend(uint id, uint lot, uint bid) public {
        fuss.tend(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_tend(uint id, uint lot, uint bid)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(fuss).call(abi.encodewithsignature(sig, id, lot, bid));
    }
    function try_deal(uint id)
        public returns (bool ok)
    {
        string memory sig = ;
        (ok,) = address(fuss).call(abi.encodewithsignature(sig, id));
    }
}

contract flaptest is dstest {
    hevm hevm;

    flapper fuss;
    address flap;
    vat     vat;
    dstoken gem;

    address ali;
    address bob;

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(604411200);

        vat = new vat();
        gem = new dstoken();

        fuss = new flapper(address(vat), address(gem));
        flap = address(fuss);

        ali = address(new guy(fuss));
        bob = address(new guy(fuss));

        vat.hope(address(fuss));
        gem.approve(address(fuss));

        vat.suck(address(this), address(this), 1000 ether);

        gem.mint(1000 ether);
        gem.setowner(flap);

        gem.push(ali, 200 ether);
        gem.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(vat.dai(address(this)), 1000 ether);
        asserteq(vat.dai(address(fuss)),    0 ether);
        fuss.kick({ lot: 100 ether
                  , bid: 0
                  });
        asserteq(vat.dai(address(this)),  900 ether);
        asserteq(vat.dai(address(fuss)),  100 ether);
    }
    function test_tend() public {
        uint id = fuss.kick({ lot: 100 ether
                            , bid: 0
                            });
        
        asserteq(vat.dai(address(this)), 900 ether);

        guy(ali).tend(id, 100 ether, 1 ether);
        
        asserteq(gem.balanceof(ali), 199 ether);
        
        asserteq(gem.balanceof(flap),  1 ether);

        guy(bob).tend(id, 100 ether, 2 ether);
        
        asserteq(gem.balanceof(bob), 198 ether);
        
        asserteq(gem.balanceof(ali), 200 ether);
        
        asserteq(gem.balanceof(flap),   2 ether);

        hevm.warp(now + 5 weeks);
        guy(bob).deal(id);
        
        asserteq(vat.dai(address(fuss)),  0 ether);
        asserteq(vat.dai(bob), 100 ether);
        
        asserteq(gem.balanceof(flap),   0 ether);
    }
    function test_beg() public {
        uint id = fuss.kick({ lot: 100 ether
                            , bid: 0
                            });
        asserttrue( guy(ali).try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!guy(bob).try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!guy(ali).try_tend(id, 100 ether, 1.01 ether));
        asserttrue( guy(bob).try_tend(id, 100 ether, 1.07 ether));
    }
}
