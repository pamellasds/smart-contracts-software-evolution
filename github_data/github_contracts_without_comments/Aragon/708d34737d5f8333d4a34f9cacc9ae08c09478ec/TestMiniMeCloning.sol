pragma solidity ^0.4.8;

import ;
import ;
import ;

contract testminimecloning {
  minimetokenfactory factory;
  ant token;
  minimetoken clone1;
  minimetoken clone2;

  uint baseblock;

  function beforeall() {
    factory = new minimetokenfactory();
    token = new ant(factory);
    token.generatetokens(this, 100);
    token.changecontroller(0xbeef); 
    baseblock = block.number;
  }

  
  

  function testhastokens() {
    assert.equal(token.balanceof(this), 100, );
  }

  function testcanclone() {
    clone1 = minimetoken(token.createclonetoken(, 18, , block.number, true));
    clone1.changecontroller(0xbeef); 
    assert.equal(clone1.balanceof(this), 100, );
    assert.equal(clone1.balanceofat(this, block.number  1), 100, );
  }

  function testcantransfer() {
    token.transfer(0x1, 10);

    assert.equal(token.balanceof(this), 90, );
    assert.equal(token.balanceofat(this, block.number  1), 100, );
    assert.equal(clone1.balanceof(this), 100, );
  }

  function testcancloneaftertransfer() {
    clone2 = minimetoken(token.createclonetoken(, 18, , block.number, true));
    clone2.changecontroller(0xbeef); 

    assert.equal(clone2.balanceof(this), 90, );
    assert.equal(clone2.balanceofat(this, block.number  2), 100, );

    clone1.transfer(0x1, 10);
    assert.equal(clone1.balanceof(this), 90, );
  }

  function testrecurringclones() {
    minimetoken lastclone = clone1;
    for (uint i = 0; i < 10; i++) {
      lastclone = minimetoken(lastclone.createclonetoken(, 18, , block.number, true));
    }
    lastclone.changecontroller(0xbeef); 

    assert.equal(lastclone.balanceof(this), 90, );
    assert.equal(lastclone.balanceofat(this, baseblock), 100, );
  }

  function testmultitransfer1() {
    assert.equal(token.balanceof(this), 90, );
    token.transfer(0x32, 10);
    assert.equal(token.balanceof(this), 80, );
  }

  function testmultitransfer2() {
    token.transfer(0x32, 10);
    assert.equal(token.balanceof(this), 70, );
  }

  function testmultitransfer3() {
    token.transfer(0x32, 10);
    assert.equal(token.balanceof(this), 60, );
    assert.equal(token.balanceofat(this, baseblock), 100, );
  }
}
