pragma solidity ^0.4.23;

import ;
import ;

import ;

contract guy {
    flopper fuss;
    constructor(flopper fuss_) public {
        fuss = fuss_;
        dstoken(fuss.pie()).approve(fuss);
        dstoken(fuss.gem()).approve(fuss);
    }
    function dent(uint id, uint lot, uint bid) public {
        fuss.dent(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_dent(uint id, uint lot, uint bid)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id, lot, bid);
    }
    function try_deal(uint id)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id);
    }
}

contract gal {}

contract warpflop is flopper {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
    constructor(address pie_, address gem_) public flopper(pie_, gem_) {}
}

contract floptest is dstest {
    warpflop fuss;
    dstoken pie;
    dstoken gem;

    guy  ali;
    guy  bob;
    gal  gal;

    function setup() public {
        pie = new dstoken();
        gem = new dstoken();

        fuss = new warpflop(pie, gem);

        fuss.warp(1 hours);

        ali = new guy(fuss);
        bob = new guy(fuss);
        gal = new gal();

        pie.approve(fuss);
        gem.approve(fuss);

        pie.mint(1000 ether);

        pie.push(ali, 200 ether);
        pie.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(pie.balanceof(this), 600 ether);
        asserteq(gem.balanceof(this),   0 ether);
        fuss.kick({ lot: uint(1)   
                  , gal: gal
                  , bid: 0
                  });
        
        asserteq(pie.balanceof(this), 600 ether);
        asserteq(gem.balanceof(this),   0 ether);
    }
    function test_dent() public {
        uint id = fuss.kick({ lot: uint(1)   
                            , gal: gal
                            , bid: 10 ether
                            });

        ali.dent(id, 100 ether, 10 ether);
        
        asserteq(pie.balanceof(ali), 190 ether);
        
        asserteq(pie.balanceof(gal),  10 ether);

        bob.dent(id, 80 ether, 10 ether);
        
        asserteq(pie.balanceof(bob), 190 ether);
        
        asserteq(pie.balanceof(ali), 200 ether);
        
        asserteq(pie.balanceof(gal), 10 ether);

        fuss.warp(5 weeks);
        asserteq(gem.totalsupply(),  0 ether);
        gem.setowner(fuss);
        bob.deal(id);
        
        asserteq(gem.totalsupply(), 80 ether);
        
        asserteq(gem.balanceof(bob), 80 ether);
    }
}
