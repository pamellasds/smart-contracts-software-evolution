pragma solidity >=0.4.10;


contract dummytoken {

    event debugtransferevent();
    event debugbalanceofevent();

    function transfer(address _to, uint _value) returns (bool) {
        debugtransferevent();
        return true;
    }

    function balanceof(address owner) returns(uint) {
        debugbalanceofevent();
        return 42;
    }
}