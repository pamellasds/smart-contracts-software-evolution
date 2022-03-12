
















pragma solidity >=0.4.23;

import ;

import ;

contract tokenuser {
    dai  token;

    constructor(dai token_) public {
        token = token_;
    }

    function dotransferfrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        return token.transferfrom(from, to, amount);
    }

    function dotransfer(address to, uint amount)
        public
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doapprove(address recipient, uint amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doallowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function dobalanceof(address who) public view returns (uint) {
        return token.balanceof(who);
    }

    function doapprove(address guy)
        public
        returns (bool)
    {
        return token.approve(guy, uint(1));
    }
    function domint(uint wad) public {
        token.mint(address(this), wad);
    }
    function doburn(uint wad) public {
        token.burn(address(this), wad);
    }
    function domint(address guy, uint wad) public {
        token.mint(guy, wad);
    }
    function doburn(address guy, uint wad) public {
        token.burn(guy, wad);
    }

}

contract hevm {
    function warp(uint256) public;
}

contract daitest is dstest {
    uint constant initialbalancethis = 1000;
    uint constant initialbalancecal = 100;

    dai token;
    hevm hevm;
    address user1;
    address user2;
    address self;

    uint amount = 2;
    uint fee = 1;
    uint nonce = 0;
    uint deadline = 0;
    address cal = 0x29c76e6ad8f28bb1004902578fb108c507be341b;
    address del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
    uint8 v = 28;
    bytes32 r = 0x46323dda87c592902a10f931e64a8160ae899d141f46b07a73e676b0e5daa1c4;
    bytes32 s = 0x6339a2fc9fdf1c0737fb35eb0928f0558170e3900da9b483ed1904bd9fdb2f87;
    bytes32 _r = 0xee602350fe5a2593bd8e4d0791bbd4e7f316e30aa9391c2519fc39b5e1cb619d;
    bytes32 _s = 0x1d31aca1f34c37c7a1b8abd7264f3b246e0da38d38427f5d18f2d1b54b0af02d;
    uint8 _v = 27;


    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);
        token = createtoken();
        token.mint(address(this), initialbalancethis);
        token.mint(cal, initialbalancecal);
        user1 = address(new tokenuser(token));
        user2 = address(new tokenuser(token));
        self = address(this);
    }

    function createtoken() internal returns (dai) {
        return new dai(99);
    }

    function testsetupprecondition() public {
        asserteq(token.balanceof(self), initialbalancethis);
    }

    function testtransfercost() public logs_gas {
        token.transfer(address(0), 10);
    }

    function testallowancestartsatzero() public logs_gas {
        asserteq(token.allowance(user1, user2), 0);
    }

    function testvalidtransfers() public logs_gas {
        uint sentamount = 250;
        emit log_named_address(, address(token));
        token.transfer(user2, sentamount);
        asserteq(token.balanceof(user2), sentamount);
        asserteq(token.balanceof(self), initialbalancethis  sentamount);
    }

    function testfailwrongaccounttransfers() public logs_gas {
        uint sentamount = 250;
        token.transferfrom(user2, self, sentamount);
    }

    function testfailinsufficientfundstransfers() public logs_gas {
        uint sentamount = 250;
        token.transfer(user1, initialbalancethis  sentamount);
        token.transfer(user2, sentamount + 1);
    }

    function testapprovesetsallowance() public logs_gas {
        emit log_named_address(, self);
        emit log_named_address(, address(token));
        emit log_named_address(, self);
        emit log_named_address(, user2);
        token.approve(user2, 25);
        asserteq(token.allowance(self, user2), 25);
    }

    function testchargesamountapproved() public logs_gas {
        uint amountapproved = 20;
        token.approve(user2, amountapproved);
        asserttrue(tokenuser(user2).dotransferfrom(self, user2, amountapproved));
        asserteq(token.balanceof(self), initialbalancethis  amountapproved);
    }

    function testfailtransferwithoutapproval() public logs_gas {
        token.transfer(user1, 50);
        token.transferfrom(user1, self, 1);
    }

    function testfailchargemorethanapproved() public logs_gas {
        token.transfer(user1, 50);
        tokenuser(user1).doapprove(self, 20);
        token.transferfrom(user1, self, 21);
    }
    function testtransferfromself() public {
        token.transferfrom(self, user1, 50);
        asserteq(token.balanceof(user1), 50);
    }
    function testfailtransferfromselfnonarbitrarysize() public {
        
        
        token.transferfrom(self, self, token.balanceof(self) + 1);
    }
    function testmintself() public {
        uint mintamount = 10;
        token.mint(address(this), mintamount);
        asserteq(token.balanceof(self), initialbalancethis + mintamount);
    }
    function testmintguy() public {
        uint mintamount = 10;
        token.mint(user1, mintamount);
        asserteq(token.balanceof(user1), mintamount);
    }
    function testfailmintguynoauth() public {
        tokenuser(user1).domint(user2, 10);
    }
    function testmintguyauth() public {
        token.rely(user1);
        tokenuser(user1).domint(user2, 10);
    }

    function testburn() public {
        uint burnamount = 10;
        token.burn(address(this), burnamount);
        asserteq(token.totalsupply(), initialbalancethis + initialbalancecal  burnamount);
    }
    function testburnself() public {
        uint burnamount = 10;
        token.burn(address(this), burnamount);
        asserteq(token.balanceof(self), initialbalancethis  burnamount);
    }
    function testburnguywithtrust() public {
        uint burnamount = 10;
        token.transfer(user1, burnamount);
        asserteq(token.balanceof(user1), burnamount);

        tokenuser(user1).doapprove(self);
        token.burn(user1, burnamount);
        asserteq(token.balanceof(user1), 0);
    }
    function testburnauth() public {
        token.transfer(user1, 10);
        token.rely(user1);
        tokenuser(user1).doburn(10);
    }
    function testburnguyauth() public {
        token.transfer(user2, 10);
        
        tokenuser(user2).doapprove(user1);
        tokenuser(user1).doburn(user2, 10);
    }

    function testfailuntrustedtransferfrom() public {
        asserteq(token.allowance(self, user2), 0);
        tokenuser(user1).dotransferfrom(self, user2, 200);
    }
    function testtrusting() public {
        asserteq(token.allowance(self, user2), 0);
        token.approve(user2, uint(1));
        asserteq(token.allowance(self, user2), uint(1));
        token.approve(user2, 0);
        asserteq(token.allowance(self, user2), 0);
    }
    function testtrustedtransferfrom() public {
        token.approve(user1, uint(1));
        tokenuser(user1).dotransferfrom(self, user2, 200);
        asserteq(token.balanceof(user2), 200);
    }
    function testapprovewillmodifyallowance() public {
        asserteq(token.allowance(self, user1), 0);
        asserteq(token.balanceof(user1), 0);
        token.approve(user1, 1000);
        asserteq(token.allowance(self, user1), 1000);
        tokenuser(user1).dotransferfrom(self, user1, 500);
        asserteq(token.balanceof(user1), 500);
        asserteq(token.allowance(self, user1), 500);
    }
    function testapprovewillnotmodifyallowance() public {
        asserteq(token.allowance(self, user1), 0);
        asserteq(token.balanceof(user1), 0);
        token.approve(user1, uint(1));
        asserteq(token.allowance(self, user1), uint(1));
        tokenuser(user1).dotransferfrom(self, user1, 1000);
        asserteq(token.balanceof(user1), 1000);
        asserteq(token.allowance(self, user1), uint(1));
    }
    function testdaiaddress() public {
        
        
        asserteq(address(token), address(0xdb356e865aaafa1e37764121ea9e801af13eeb83));
    }

    function testtypehash() public {
      asserteq(token.permit_typehash(), 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb);
    }

    function testdomain_separator() public {
      asserteq(token.domain_separator(), 0x92a148ae95a9faf19ab88b195b0da85dd00a6764ac8a66d5e64fb3add1579cac);
    }

    function testpermit() public {
        asserteq(token.nonces(cal),0);
        asserteq(token.allowance(cal, del),0);
        token.permit(cal, del, 0, 0, true, v, r, s);
        asserteq(token.allowance(cal, del),uint(1));
        asserteq(token.nonces(cal),1);
    }

    function testpermitwithexpiry() public {
      asserteq(now, 0);
      token.permit(cal, del, 0, 1, true, _v, _r, _s);
      asserteq(token.allowance(cal, del),uint(1));
      asserteq(token.nonces(cal),1);
    }

    function testfailpermitwithexpiry() public {
      hevm.warp(2);
      asserteq(now, 2);
      token.permit(cal, del, 0, 1, true, _v, _r, _s);
    }

    function testfailreplay() public {
      token.permit(cal, del, 0, 0, true, v, r, s);
      token.permit(cal, del, 0, 0, true, v, r, s);
    }
}
